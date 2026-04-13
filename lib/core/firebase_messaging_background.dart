import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isNotEmpty) return;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
      return;
    case TargetPlatform.iOS:
      await Firebase.initializeApp();
      return;
    default:
      return;
  }
}
