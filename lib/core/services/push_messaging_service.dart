import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

/// Firebase Cloud Messaging: token in Firestore for server-side sends; foreground → local notification.
class PushMessagingService {
  PushMessagingService._();
  static final PushMessagingService instance = PushMessagingService._();

  bool _started = false;

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
    auth.authStateChanges().listen((user) => _syncToken(user?.uid));

    FirebaseMessaging.onMessage.listen((RemoteMessage msg) async {
      final title = msg.notification?.title ?? msg.data['title'] ?? 'Labby';
      final body = msg.notification?.body ?? msg.data['body'] ?? '';
      if (body.isEmpty) return;
      await NotificationService.instance.showImmediate(title: title, body: body);
    });
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
