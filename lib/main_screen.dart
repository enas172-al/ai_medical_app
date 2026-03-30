import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/medication/medication_screen.dart';
import 'package:ai_medical_app/features/history/history_screen.dart';
import 'package:ai_medical_app/features/profile/profile_screen.dart';

import 'core/widgets/custom_app_bar.dart';
import 'core/widgets/custom_bottom_nav_bar.dart';
import 'features/home/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    MedicationScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  final List<String> titles = [
    "",
    "الدواء",
    "السجل",
    "الملف الشخصي ",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ///  AppBar الموحد
      appBar: CustomAppBar(
        isHome: currentIndex == 0,
        title: titles[currentIndex],
        notificationCount: 3,
      ),


      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      ///  Bottom Navigation
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (currentIndex == index) return;

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}