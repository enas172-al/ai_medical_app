import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local daily reminders for medications (complements FCM later).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _inited = false;
  bool _tzLoaded = false;

  static const _channelId = 'labby_medications';
  static const _channelName = 'Medication reminders';
  static const _generalChannelId = 'labby_general';
  static const _generalChannelName = 'Labby alerts';
  static const _periodicChannelId = 'labby_periodic';
  static const _periodicChannelName = 'Periodic lab reminders';

  static const String _payloadKeyType = 't';
  static const String _payloadTypeMedication = 'med';
  static const String _payloadKeyMedicationName = 'mn';
  static const String _payloadKeySnoozeMinutes = 'sm';

  static const String _actionSnooze10 = 'snooze_10';
  static const int _snoozeMinutes10 = 10;
  static const int _snoozeIdBase = 800000000; // keep far away from medication IDs

  // Stable IDs for periodic lab reminders.
  static const int _periodicIdMonthly = 900001;
  static const int _periodicIdSemiAnnual = 900002;

  bool get _supportsLocalSchedule =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// Light init only (no timezone DB) — avoids blocking first app frames / Run.
  Future<void> init() async {
    if (kIsWeb || _inited) return;
    if (!_supportsLocalSchedule) {
      _inited = true;
      return;
    }

    final androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    final darwinInit = DarwinInitializationSettings(
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'med_snooze',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              _actionSnooze10,
              'غفوة 10 دقائق',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.authenticationRequired,
              },
            ),
          ],
        ),
      ],
    );
    await _plugin.initialize(
      settings: InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isAndroid) {
      await _ensureAndroidChannels();
    }

    _inited = true;
  }

  Future<void> _ensureAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Take medication on time',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _generalChannelId,
        _generalChannelName,
        description: 'Lab results and push messages',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _periodicChannelId,
        _periodicChannelName,
        description: 'Periodic lab check reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ),
    );
  }

  /// Android only: deletes and recreates notification channels.
  /// Useful when channels were muted/silenced in system settings (Android won't update channel importance after creation).
  Future<void> resetAndroidNotificationChannels() async {
    if (!_supportsLocalSchedule || !Platform.isAndroid) return;
    if (!_inited) await init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    try {
      await android.deleteNotificationChannel(channelId: _channelId);
      await android.deleteNotificationChannel(channelId: _generalChannelId);
      await android.deleteNotificationChannel(channelId: _periodicChannelId);
    } catch (_) {
      // ignore
    }
    await _ensureAndroidChannels();
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    NotificationService.instance._handleNotificationResponse(response);
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse response) {
    // Note: background isolate; keep logic minimal and resilient.
    NotificationService.instance._handleNotificationResponse(response);
  }

  Future<void> _handleNotificationResponse(NotificationResponse response) async {
    if (!_supportsLocalSchedule) return;
    if (!_inited) {
      // Ensure plugin is ready for scheduling when app is launched from background action.
      await init();
    }

    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final type = data[_payloadKeyType]?.toString();
    if (type != _payloadTypeMedication) return;

    final medicationName = data[_payloadKeyMedicationName]?.toString();
    if (medicationName == null || medicationName.isEmpty) return;

    // Only handle snooze action; a normal tap can be handled by navigation elsewhere if needed.
    if (response.actionId != _actionSnooze10) return;

    final minsRaw = data[_payloadKeySnoozeMinutes];
    final snoozeMins = minsRaw is int ? minsRaw : int.tryParse(minsRaw?.toString() ?? '');
    if (snoozeMins == null || snoozeMins <= 0) return;

    await _scheduleSnoozeMedicationReminder(
      medicationName: medicationName,
      minutes: snoozeMins,
    );
  }

  /// Immediate banner (FCM foreground, abnormal lab save, etc.).
  Future<void> showImmediate({required String title, required String body}) async {
    if (kIsWeb || !_supportsLocalSchedule) return;
    if (!_inited) await init();
    final id = DateTime.now().millisecondsSinceEpoch.remainder(0x3FFFFFFF);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _generalChannelId,
          _generalChannelName,
          icon: '@mipmap/launcher_icon',
          channelDescription: 'Lab results and push messages',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFF1FB6A6),
          enableLights: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }

  Future<void> cancelPeriodicLabReminders() async {
    if (!_supportsLocalSchedule) return;
    await _plugin.cancel(id: _periodicIdMonthly);
    await _plugin.cancel(id: _periodicIdSemiAnnual);
  }

  /// Schedules periodic lab reminders as one-shot notifications.
  /// Called on startup; will overwrite previous schedules.
  Future<void> schedulePeriodicLabReminders({
    required String monthlyTitle,
    required String monthlyBody,
    required String semiAnnualTitle,
    required String semiAnnualBody,
    int hour = 9,
    int minute = 0,
  }) async {
    if (!_supportsLocalSchedule) return;
    if (!_inited) await init();
    await _ensureTimezoneLoaded();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _periodicChannelId,
        _periodicChannelName,
        icon: '@mipmap/launcher_icon',
        channelDescription: 'Periodic lab check reminders',
        importance: Importance.max,
        priority: Priority.max,
        color: const Color(0xFF1FB6A6),
        enableLights: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
      ),
    );

    await cancelPeriodicLabReminders();

    final now = tz.TZDateTime.now(tz.local);
    final baseToday = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    final first = baseToday.isAfter(now) ? baseToday : baseToday.add(const Duration(days: 1));

    final monthlyWhen = first.add(const Duration(days: 30));
    final semiAnnualWhen = first.add(const Duration(days: 180));

    await _plugin.zonedSchedule(
      id: _periodicIdMonthly,
      scheduledDate: monthlyWhen,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: monthlyTitle,
      body: monthlyBody,
    );

    await _plugin.zonedSchedule(
      id: _periodicIdSemiAnnual,
      scheduledDate: semiAnnualWhen,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: semiAnnualTitle,
      body: semiAnnualBody,
    );
  }

  /// Heavy: load timezone data only when scheduling (not at app startup).
  Future<void> _ensureTimezoneLoaded() async {
    if (_tzLoaded) return;
    tz_data.initializeTimeZones();
    try {
      // flutter_timezone may return either a String or a TimezoneInfo (depending on version).
      final Object info = await FlutterTimezone.getLocalTimezone();
      late final String tzName;
      if (info is String) {
        tzName = info;
      } else {
        final id = (info as dynamic).identifier;
        tzName = id is String ? id : id.toString();
      }
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _tzLoaded = true;
  }

  Future<void> requestPermissionsIfNeeded() async {
    if (!_supportsLocalSchedule) return;
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<AndroidScheduleMode> _androidScheduleModeForAlarms() async {
    // Important: do NOT request exact-alarm permission here (it opens settings UI).
    // We only *check* capability and pick the best mode.
    if (!Platform.isAndroid) return AndroidScheduleMode.inexactAllowWhileIdle;
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try {
      final ok = await android?.canScheduleExactNotifications();
      if (ok == true) return AndroidScheduleMode.exactAllowWhileIdle;
    } catch (_) {
      // ignore and fallback
    }
    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<bool?> areNotificationsEnabled() async {
    if (!_supportsLocalSchedule) return null;
    if (!_inited) await init();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled();
    }
    return true;
  }

  static int _notificationId(String medId, int slot) =>
      (medId.hashCode ^ slot).abs() % 0x7FFFFFFF;

  static int? _timeStringToMinutes(String timeStr) {
    try {
      final str = timeStr.trim().replaceAll('ص', 'صباحاً').replaceAll('م', 'مساءً');
      final parts = str.split(' ');
      final timeParts = parts[0].split(':');
      int h = int.parse(timeParts[0]);
      int m = int.parse(timeParts[1]);
      if (parts.length > 1) {
        final tail = parts.sublist(1).join(' ');
        final tailLower = tail.toLowerCase();
        final isPm = tail.contains('ظهر') ||
            tail.contains('مساء') ||
            tailLower.contains('pm') ||
            tailLower.contains('p.m');
        final isAm = tail.contains('صباح') ||
            tailLower.contains('am') ||
            tailLower.contains('a.m');

        if (isPm && h != 12) h += 12;
        if (isAm && h == 12) h = 0;
      }
      return h * 60 + m;
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelMedicationReminders(String? medId) async {
    if (!_supportsLocalSchedule || medId == null || medId.isEmpty) return;
    // We schedule up to 32 notifications per medication:
    // for each time slot we schedule the main reminder and a +10min repeat.
    // (Using a fixed cap keeps cancellation simple even if the time list changes.)
    for (var i = 0; i < 32; i++) {
      await _plugin.cancel(id: _notificationId(medId, i));
    }
  }

  Future<void> scheduleMedicationReminders({
    required String medId,
    required String medicationName,
    required List<String> times,
    required String frequency,
    required DateTime anchorDateTime,
    required List<int> daysOfWeek,
  }) async {
    if (!_supportsLocalSchedule) return;
    if (!_inited) await init();
    await _ensureTimezoneLoaded();
    await cancelMedicationReminders(medId);

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        icon: '@mipmap/launcher_icon',
        channelDescription: 'Take medication on time',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            _actionSnooze10,
            'غفوة 10 دقائق',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'med_snooze',
      ),
    );

    const minLead = Duration(minutes: 10);

    tz.TZDateTime nextDailyAt(int hour, int minute) {
      final now = tz.TZDateTime.now(tz.local);
      final base = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (base.isBefore(now)) return base.add(const Duration(days: 1));
      if (base.difference(now) < minLead) return base.add(const Duration(days: 1));
      return base;
    }

    tz.TZDateTime nextWeeklyAt({
      required int weekday, // 1=Mon..7=Sun
      required int hour,
      required int minute,
    }) {
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime candidate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      while (candidate.weekday != weekday || !candidate.isAfter(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      if (candidate.difference(now) < minLead) {
        candidate = candidate.add(const Duration(days: 7));
      }
      return candidate;
    }

    tz.TZDateTime nextMonthlyAt({
      required int dayOfMonth,
      required int hour,
      required int minute,
    }) {
      final now = tz.TZDateTime.now(tz.local);
      int safeDay = dayOfMonth;
      if (safeDay < 1) safeDay = 1;
      if (safeDay > 28) safeDay = 28; // keep valid for all months
      tz.TZDateTime candidate = tz.TZDateTime(tz.local, now.year, now.month, safeDay, hour, minute);
      if (!candidate.isAfter(now)) {
        // move to next month
        final nextMonth = (now.month == 12) ? 1 : now.month + 1;
        final nextYear = (now.month == 12) ? now.year + 1 : now.year;
        candidate = tz.TZDateTime(tz.local, nextYear, nextMonth, safeDay, hour, minute);
      }
      if (candidate.difference(now) < minLead) {
        final nextMonth = (candidate.month == 12) ? 1 : candidate.month + 1;
        final nextYear = (candidate.month == 12) ? candidate.year + 1 : candidate.year;
        candidate = tz.TZDateTime(tz.local, nextYear, nextMonth, safeDay, hour, minute);
      }
      return candidate;
    }

    final payload = jsonEncode(<String, dynamic>{
      _payloadKeyType: _payloadTypeMedication,
      _payloadKeyMedicationName: medicationName,
      _payloadKeySnoozeMinutes: _snoozeMinutes10,
    });
    final androidMode = await _androidScheduleModeForAlarms();

    if (frequency == 'weekly') {
      if (times.isEmpty) return;
      final mins = _timeStringToMinutes(times.first);
      if (mins == null) return;
      final h = mins ~/ 60;
      final m = mins % 60;
      final weekday = daysOfWeek.isNotEmpty ? daysOfWeek.first : anchorDateTime.weekday;
      final when = nextWeeklyAt(weekday: weekday, hour: h, minute: m);
      await _plugin.zonedSchedule(
        id: _notificationId(medId, 0),
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: androidMode,
        title: _channelName,
        body: medicationName,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      return;
    }

    if (frequency == 'monthly') {
      if (times.isEmpty) return;
      final mins = _timeStringToMinutes(times.first);
      if (mins == null) return;
      final h = mins ~/ 60;
      final m = mins % 60;
      final dayOfMonth = anchorDateTime.day;
      final when = nextMonthlyAt(dayOfMonth: dayOfMonth, hour: h, minute: m);
      await _plugin.zonedSchedule(
        id: _notificationId(medId, 0),
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: androidMode,
        title: _channelName,
        body: medicationName,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
      return;
    }

    // Default: daily schedules (once/twice/three times daily)
    for (var i = 0; i < times.length; i++) {
      final mins = _timeStringToMinutes(times[i]);
      if (mins == null) continue;
      final h = mins ~/ 60;
      final m = mins % 60;
      final when = nextDailyAt(h, m);
      await _plugin.zonedSchedule(
        id: _notificationId(medId, i),
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: androidMode,
        title: _channelName,
        body: medicationName,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _scheduleSnoozeMedicationReminder({
    required String medicationName,
    required int minutes,
  }) async {
    if (!_supportsLocalSchedule) return;
    if (!_inited) await init();
    await _ensureTimezoneLoaded();

    final now = tz.TZDateTime.now(tz.local);
    final when = now.add(Duration(minutes: minutes));

    // Unique one-shot ID so we don't overwrite the daily schedule.
    final id = _snoozeIdBase + (DateTime.now().millisecondsSinceEpoch.remainder(100000000));

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        icon: '@mipmap/launcher_icon',
        channelDescription: 'Take medication on time',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction(
            _actionSnooze10,
            'غفوة 10 دقائق',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'med_snooze',
      ),
    );

    final payload = jsonEncode(<String, dynamic>{
      _payloadKeyType: _payloadTypeMedication,
      _payloadKeyMedicationName: medicationName,
      _payloadKeySnoozeMinutes: minutes,
    });

    final androidMode = await _androidScheduleModeForAlarms();
    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: androidMode,
      title: _channelName,
      body: medicationName,
      payload: payload,
    );
  }
}
