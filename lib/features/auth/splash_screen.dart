import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentDot = 0;

  @override
  void initState() {
    super.initState();

    // حركة النقاط
    Future.delayed(Duration(milliseconds: 500), updateDots);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.pushReplacementNamed(context, user == null ? '/login' : '/home');
    });
  }

  void updateDots() {
    if (!mounted) return;

    setState(() {
      currentDot = (currentDot + 1) % 3;
    });

    Future.delayed(Duration(milliseconds: 500), updateDots);
  }

  Widget buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: currentDot == index ? 10 : 6,
      height: currentDot == index ? 10 : 6,
      decoration: BoxDecoration(
        color: currentDot == index ? Colors.white : Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1FB6A6),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //  Logo
              Image.asset(
                'assets/images/logo.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 20),

              // اسم التطبيق
              Text(
                "labby_title".tr(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 8),

              // الشعار
              Text(
                "app_slogan".tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              SizedBox(height: 30),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildDot(0),
                  buildDot(1),
                  buildDot(2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}