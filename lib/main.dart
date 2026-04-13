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
import 'core/services/notification_service.dart';
import 'main_screen.dart';
import 'features/chart/chart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Light init only (channel + plugin). Timezone DB loads lazily when scheduling a reminder.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    NotificationService.instance.init().then((_) {}, onError: (Object e, StackTrace st) {
      debugPrint('NotificationService.init failed: $e');
    });
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
        '/home': (context) => MainScreen(),
        '/result': (context) => ResultScreen(),
        '/chart': (context) => ChartScreen(),
      },
    );
  }
}
