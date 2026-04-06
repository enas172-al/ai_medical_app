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
  bool _isDashboardVisible = false;

  void _toggleDashboard(bool visible) {
    setState(() {
      _isDashboardVisible = visible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We define pages inside build to capture the _toggleDashboard callback
    final List<Widget> pages = [
      HomeScreen(
        isDashboardVisible: _isDashboardVisible,
        onToggleDashboard: _toggleDashboard,
      ),
      const HistoryScreen(),
      const MedicationScreen(),
      const ProfileScreen(),
    ];

    final List<String> titles = [
      "",
      "السجل",
      "أدويتي",
      "الملف الشخصي",
    ];

    return Scaffold(
      ///  AppBar الموحد - يختفي عند عرض لوحة التحكم المطورة
      appBar: (currentIndex == 0 && _isDashboardVisible)
          ? null
          : CustomAppBar(
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
            // إغلاق لوحة التحكم عند التنقل لتبويب آخر
            if (index != 0) {
              _isDashboardVisible = false;
            }
          });
        },
      ),
    );
  }
}