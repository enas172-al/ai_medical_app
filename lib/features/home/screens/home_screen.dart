import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'home_detail_screen.dart';
import 'dashboard_screen.dart';
import 'package:ai_medical_app/features/scan/scan_screen.dart';
import '../../results/view/screens/analysis_detail_screen.dart';
import '../../../core/models/analysis_model.dart';
import '../../../core/services/database_service.dart';

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

    final user = FirebaseAuth.instance.currentUser;
    final userName = (user?.displayName?.trim().isNotEmpty == true)
        ? user!.displayName!.trim()
        : (user?.email?.split('@').first.trim().isNotEmpty == true)
            ? user!.email!.split('@').first.trim()
            : "anonymous_user".tr();
    final userId = user?.uid;

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
                  "welcome_user".tr(args: [userName]),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                            color: Colors.white.withValues(alpha: 0.2),
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

                if (userId == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "history_sign_in".tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  StreamBuilder<List<AnalysisModel>>(
                    stream: DatabaseService().getAnalyses(userId),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "${"no_data_found".tr()} (${snap.error})",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final items = snap.data ?? const <AnalysisModel>[];
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "history_empty".tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final top = items.take(3).toList();
                      final latestDate = _formatShortDate(items.first.date);

                      return Column(
                        children: [
                          for (final a in top)
                            _buildResultCardFromAnalysis(context, a),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                latestDate,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 30),

                // تم إخفاء قسم "التنبيهات والتذكيرات" لتفادي لخبطة المستخدم.
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatShortDate(DateTime d) {
    // Keep formatting dependency-free.
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  static String _localizedStatus(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'high') return "high_status".tr();
    if (s == 'low') return "low_status".tr();
    return "normal_status".tr();
  }

  static ({Color fg, Color bg, Color border}) _statusPalette(String localizedStatus) {
    if (localizedStatus == "high_status".tr()) {
      return (fg: const Color(0xFFF5222D), bg: const Color(0xFFFFF1F0), border: const Color(0xFFFFA39E));
    }
    if (localizedStatus == "low_status".tr()) {
      return (fg: const Color(0xFFC77800), bg: const Color(0xFFFFFDF5), border: const Color(0xFFFFE082));
    }
    return (fg: const Color(0xFF52C41A), bg: const Color(0xFFF6FFED), border: const Color(0xFFB7EB8F));
  }

  Widget _buildResultCardFromAnalysis(BuildContext context, AnalysisModel a) {
    final status = _localizedStatus(a.status);
    final pal = _statusPalette(status);
    return _buildResultCard(
      context,
      a.testName,
      a.value.toString(),
      a.unit,
      status,
      pal.fg,
      pal.bg,
      pal.border,
      date: _formatShortDate(a.date),
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
    {required String date}
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
              date: date,
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
              color: Colors.black.withValues(alpha: 0.02),
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

  // Reminder cards were removed to avoid confusing users.
}