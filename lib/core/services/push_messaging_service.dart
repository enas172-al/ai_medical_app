import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';
import 'notifications_repository.dart';

/// Firebase Cloud Messaging: token in Firestore for server-side sends; foreground → local notification.
class PushMessagingService {
  PushMessagingService._();
  static final PushMessagingService instance = PushMessagingService._();

  bool _started = false;
  StreamSubscription? _firestoreNotifSub;
  String? _lastSeenNotifId;

  Future<void> init() async {
    if (kIsWeb || _started) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;
    _started = true;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final auth = FirebaseAuth.instance;
    await _syncToken(auth.currentUser?.uid);
    auth.authStateChanges().listen((user) {
      _syncToken(user?.uid);
      _startFirestoreNotificationListener(user?.uid);
    });
    _startFirestoreNotificationListener(auth.currentUser?.uid);

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      final title = msg.notification?.title ?? msg.data['title'] ?? 'Labby';
      final body = msg.notification?.body ?? msg.data['body'] ?? '';
      if (body.isEmpty) return;
      await NotificationService.instance.showImmediate(title: title, body: body);

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final route = msg.data['route'] as String?;
        final type = (msg.data['type'] as String?)?.trim();
        await NotificationsRepository().addForUser(
          userId: uid,
          title: title,
          body: body,
          type: (type == null || type.isEmpty) ? 'general' : type,
          data: {
            if (route != null && route.isNotEmpty) 'route': route,
            ...msg.data,
          },
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final title = msg.notification?.title ?? msg.data['title'] ?? 'Labby';
      final body = msg.notification?.body ?? msg.data['body'] ?? '';
      if (body.isEmpty) return;
      await NotificationsRepository().addForUser(
        userId: uid,
        title: title,
        body: body,
        type: (msg.data['type'] as String?)?.trim() ?? 'general',
        data: msg.data,
      );
    });
  }

  void _startFirestoreNotificationListener(String? uid) {
    _firestoreNotifSub?.cancel();
    _firestoreNotifSub = null;
    _lastSeenNotifId = null;
    if (uid == null) return;

    // Important:
    // We do NOT mirror Firestore feed items into immediate local notifications.
    // This was causing "instant" notifications right after local writes (e.g. medication add).
    // Scheduled medication reminders should be handled by local schedules at their exact times.
    // Push notifications are already handled by FCM (system notifications).
    return;

    // While the app is running, show a local notification for newly-added docs in Firestore.
    _firestoreNotifSub = NotificationsRepository().watchForUser(uid, limit: 1).listen(
      (list) async {
        if (list.isEmpty) return;
        final n = list.first;
        if (_lastSeenNotifId == null) {
          // First snapshot is baseline (avoid notifying old items on app start).
          _lastSeenNotifId = n.id;
          return;
        }
        if (n.id == _lastSeenNotifId) return;
        _lastSeenNotifId = n.id;
        await NotificationService.instance.showImmediate(title: n.title, body: n.body);
      },
      onError: (_) {},
    );
  }

  Future<void> _syncToken(String? uid) async {
    if (uid == null) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FCM token sync: $e');
    }
  }
}
