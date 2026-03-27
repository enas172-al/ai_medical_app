import 'package:flutter/material.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';

import 'features/auth/register_screen.dart';
import 'features/home/home_screen.dart'; // ✔ صح
import 'features/history/history_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/search/search_screen.dart';
import 'features/results/result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Labby',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1FB6A6),
        ),
        fontFamily: 'Cairo',
      ),

      home: SplashScreen(),

      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/history': (context) => HistoryScreen(),
        '/profile': (context) => ProfileScreen(),
        '/result': (context) => ResultScreen(),
      },
    );
  }
}