// Generated from android/app/google-services.json (project labby-31347).
// Run `dart pub global activate flutterfire_cli` then `flutterfire configure` to regenerate for all platforms.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase: add a Web app in Firebase Console, then run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase: add iOS/macOS in Console, add GoogleService-Info.plist, then flutterfire configure.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        // Same Firebase project as Android; for release desktop use flutterfire configure.
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMH32kVY4VWkg9BDS-OtRCPgWv13f7uTw',
    appId: '1:217984859415:android:fd28043a10c6e330140b52',
    messagingSenderId: '217984859415',
    projectId: 'labby-31347',
    storageBucket: 'labby-31347.firebasestorage.app',
  );
}
