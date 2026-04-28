import 'dart:io';
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

  static const String _payloadKeyType = 't';
  static const String _payloadTypeMedication = 'med';
  static const String _payloadKeyMedicationName = 'mn';
  static const String _payloadKeySnoozeMinutes = 'sm';

  static const int _snoozeMinutes10 = 10;

  bool get _supportsLocalSchedule =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// Light init only (no timezone DB) — avoids blocking first app frames / Run.
  Future<void> init() async {
    if (kIsWeb || _inited) return;
    if (!_supportsLocalSchedule) {
      _inited = true;
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
    );

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Take medication on time',
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          _generalChannelName,
          description: 'Lab results and push messages',
          importance: Importance.high,
        ),
      );
    }

    _inited = true;
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
          channelDescription: 'Lab results and push messages',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
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
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<AndroidScheduleMode> _androidScheduleModeForAlarms() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.inexactAllowWhileIdle;
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try {
      final ok = await android?.canScheduleExactNotifications();
      if (ok == true) return AndroidScheduleMode.exactAllowWhileIdle;
    } catch (_) {
      // ignore
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
        if ((tail.contains('ظهر') || tail.contains('مساء')) && h != 12) h += 12;
        if (tail.contains('صباح') && h == 12) h = 0;
      }
      return h * 60 + m;
    } catch (_) {
      return null;
    }
  }

  Future<void> cancelMedicationReminders(String? medId) async {
    if (!_supportsLocalSchedule || medId == null || medId.isEmpty) return;
    for (var i = 0; i < 8; i++) {
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
        channelDescription: 'Take medication on time',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    const minLead = Duration(minutes: 10);

    tz.TZDateTime nextDailyAt(int hour, int minute) {
      final now = tz.TZDateTime.now(tz.local);
      final base = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (base.isBefore(now)) return base.add(const Duration(days: 1));
      // Avoid "instant" notifications right after adding (user expectation).
      if (base.difference(now) < minLead) {
        return base.add(const Duration(days: 1));
      }
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
      if (safeDay > 28) safeDay = 28;
      tz.TZDateTime candidate = tz.TZDateTime(tz.local, now.year, now.month, safeDay, hour, minute);
      if (!candidate.isAfter(now)) {
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
      final when = nextMonthlyAt(dayOfMonth: anchorDateTime.day, hour: h, minute: m);
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

    for (var i = 0; i < times.length; i++) {
      final mins = _timeStringToMinutes(times[i]);
      if (mins == null) continue;
      final h = mins ~/ 60;
      final m = mins % 60;
      final when = nextDailyAt(h, m);
      debugPrint('Schedule med=$medId slot=$i when=$when freq=$frequency time=${times[i]}');
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
}
