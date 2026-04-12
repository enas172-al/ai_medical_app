import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'home_detail_screen.dart';
import 'dashboard_screen.dart';
import 'package:ai_medical_app/features/scan/scan_screen.dart';
import '../../results/view/screens/analysis_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isDashboardVisible;
  final Function(bool)? onToggleDashboard;

  const HomeScreen({
    super.key,
    this.isDashboardVisible = false,
    this.onToggleDashboard,
  });

  @override
  Widget build(BuildContext context) {
    if (isDashboardVisible) {
      return DashboardScreen(
        onBack: () {
          if (onToggleDashboard != null) {
            onToggleDashboard!(false);
          }
        },
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///  ترحيب
                Text(
                  "welcome_user".tr(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "how_are_you_today".tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "ai_in_medicine".tr(),
                    style: const TextStyle(
                      color: Color(0xFF1FB6A6),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                ///  لوحة المتابعة الصحية (Purple)
                GestureDetector(
                  onTap: () {
                    if (onToggleDashboard != null) {
                      onToggleDashboard!(true);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.bar_chart, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "health_tracking_dashboard".tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "track_health_comprehensively".tr(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ///صور التحاليل الطبية (Teal)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FB6A6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "scan_medical_tests".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "capture_clear_image_for_analysis".tr(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                /// 🧪 آخر تحليل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeDetailScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, color: Color(0xFF1FB6A6), size: 16),
                          const SizedBox(width: 4),
                          Text("view_details".tr(), style: const TextStyle(color: Color(0xFF1FB6A6))),
                        ],
                      ),
                    ),
                    Text(
                      "latest_analysis".tr(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                _buildResultCard(
                  context,
                  "fasting_sugar".tr(),
                  "95",
                  "mg/dL",
                  "normal_status".tr(),
                  const Color(0xFF52C41A),
                  const Color(0xFFF6FFED),
                  const Color(0xFFB7EB8F),
                ),
                _buildResultCard(
                  context,
                  "cholesterol".tr(),
                  "220",
                  "mg/dL",
                  "high_status".tr(),
                  const Color(0xFFF5222D),
                  const Color(0xFFFFF1F0),
                  const Color(0xFFFFA39E),
                ),

                _buildResultCard(
                  context,
                  "blood_pressure".tr(),
                  "120/80",
                  "mmHg",
                  "normal_status".tr(),
                  const Color(0xFF52C41A),
                  const Color(0xFFF6FFED),
                  const Color(0xFFB7EB8F),
                ),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      "20 مارس 2026",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔔 التنبيهات والتذكيرات
                Text(
                  "alerts_and_reminders".tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                _buildReminderCard(
                  title: "medication_time".tr(),
                  subtitle: "bp_med_reminder".tr(),
                  icon: Icons.notifications_none,
                  color: const Color(0xFFC77800),
                  backgroundColor: const Color(0xFFFFFDF5),
                  borderColor: const Color(0xFFFFE082),
                ),
                const SizedBox(height: 12),
                _buildReminderCard(
                  title: "test_reminder".tr(),
                  subtitle: "hba1c_reminder".tr(),
                  icon: Icons.notifications_none,
                  color: const Color(0xFF1565C0),
                  backgroundColor: const Color(0xFFF0F7FF),
                  borderColor: const Color(0xFFBBDEFB),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    String title,
    String value,
    String unit,
    String status,
    Color statusColor,
    Color statusBg,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisDetailScreen(
              name: title,
              value: value,
              unit: unit,
              status: status,
              date: "2024-04-01",
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "$unit $value",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Icon(
                    status == "normal_status".tr() ? Icons.check : Icons.error_outline,
                    color: statusColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: color.withOpacity(0.8), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}