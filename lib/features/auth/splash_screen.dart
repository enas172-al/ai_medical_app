import 'package:flutter/material.dart';

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

    // 🔥 الانتقال إلى Login
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
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

              // 🧪 Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.science,
                  color: Color(0xFF1FB6A6),
                  size: 40,
                ),
              ),

              SizedBox(height: 20),

              // اسم التطبيق
              Text(
                "labby",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 8),

              // الشعار
              Text(
                "رفيقك في رحلة الصحة",
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