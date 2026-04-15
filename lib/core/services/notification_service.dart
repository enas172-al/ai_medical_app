import 'dart:io';

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

    for (var i = 0; i < times.length; i++) {
      final mins = _timeStringToMinutes(times[i]);
      if (mins == null) continue;
      final h = mins ~/ 60;
      final m = mins % 60;
      final now = tz.TZDateTime.now(tz.local);
      final baseToday = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
      // If the user adds the medication at the exact reminder minute (or shortly after),
      // show an immediate notification once, then schedule the daily repeating reminder from tomorrow.
      if (baseToday.isBefore(now) && now.difference(baseToday) <= const Duration(minutes: 1)) {
        await showImmediate(title: _channelName, body: medicationName);
      }
      final when = baseToday.isBefore(now) ? baseToday.add(const Duration(days: 1)) : baseToday;

      await _plugin.zonedSchedule(
        id: _notificationId(medId, i),
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: _channelName,
        body: medicationName,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
