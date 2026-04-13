import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Initializes Firebase `[DEFAULT]`.
///
/// - Android may already be initialized natively from `google-services.json`; we skip if an app exists.
/// - Catches `duplicate-app` races between native and Dart init.
/// - Windows/Linux: uses the same [DefaultFirebaseOptions.android] project config so `flutter run -d windows`
///   works without a separate Desktop registration (for production, run `flutterfire configure` for real desktop keys).
Future<void> initializeFirebaseApp() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }

  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        await Firebase.initializeApp();
        return;
      case TargetPlatform.android:
        await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
        return;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        if (kDebugMode) {
          debugPrint(
            'Firebase: initializing desktop with Android project options '
            '(add a Desktop app + flutterfire configure for production).',
          );
        }
        await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
        return;
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app' || e.code.contains('duplicate')) {
      return;
    }
    if (kDebugMode) {
      debugPrint('Firebase.initializeApp failed: $e');
    }
    rethrow;
  } catch (e, st) {
    final msg = e.toString();
    if (msg.contains('duplicate-app') || msg.contains('[core/duplicate-app]')) {
      return;
    }
    if (kDebugMode) {
      debugPrint('Firebase.initializeApp failed: $e\n$st');
    }
    rethrow;
  }
}
