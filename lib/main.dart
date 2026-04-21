import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/history/history_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/search/search_screen.dart';
import 'features/results/view/screens/result_screen.dart';
import 'core/firebase_bootstrap.dart';
import 'core/firebase_messaging_background.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_messaging_service.dart';
import 'core/services/medication_reminder_sync_service.dart';
import 'core/services/periodic_analysis_reminder_service.dart';
import 'main_screen.dart';
import 'features/chart/chart_screen.dart';
import 'core/widgets/biometric_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      default:
        break;
    }
  }

  await Future.wait([
    EasyLocalization.ensureInitialized(),
    initializeFirebaseApp(),
  ]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await NotificationService.instance.init();
      await PushMessagingService.instance.init();
      MedicationReminderSyncService.instance.start();
      PeriodicAnalysisReminderService.instance.start();
    } catch (e, st) {
      debugPrint('Notification/FCM init failed: $e\n$st');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      title: 'app_title'.tr(),

      home: SplashScreen(),

      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/history': (context) => HistoryScreen(),
        '/profile': (context) => ProfileScreen(),
        '/search': (context) => SearchScreen(),
        '/home': (context) => const BiometricGate(child: MainScreen()),
        '/result': (context) => ResultScreen(),
        '/chart': (context) => ChartScreen(),
      },
    );
  }
}
