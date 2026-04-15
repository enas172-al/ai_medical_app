import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isNotEmpty) return;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
      break;
    case TargetPlatform.iOS:
      await Firebase.initializeApp();
      break;
    default:
      return;
  }

  // Best-effort persistence for background notifications (requires userId in data payload).
  try {
    final userId = (message.data['userId'] as String?)?.trim();
    final title = message.notification?.title ?? message.data['title'] ?? 'Labby';
    final body = message.notification?.body ?? message.data['body'] ?? '';
    if (userId == null || userId.isEmpty || body.isEmpty) return;

    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': (message.data['type'] as String?)?.trim() ?? 'general',
      'data': message.data,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {}
}
