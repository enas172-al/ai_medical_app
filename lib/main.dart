import 'package:flutter/material.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';

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

      // البداية
      home: SplashScreen(),

      // routes (مهم لاحقًا)
      routes: {
        '/login': (context) => LoginScreen(),
      },
    );
  }
}