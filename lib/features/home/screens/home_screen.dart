import 'package:flutter/material.dart';
import 'home_detail_screen.dart';
import 'dashboard_screen.dart';
import 'package:ai_medical_app/features/scan/scan_screen.dart';

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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 👋 ترحيب
                const Text(
                  "مرحباً أحمد",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "كيف حالك اليوم؟",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "✨ الذكاء الاصطناعي في الطب",
                    style: TextStyle(
                      color: Color(0xFF1FB6A6),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                /// 📊 لوحة المتابعة الصحية (Purple)
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
                            children: const [
                              Text(
                                "لوحة المتابعة الصحية",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "تتبع صحتك بشكل شامل ومفصل",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// 📷 صور التحاليل الطبية (Teal)
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
                        const Text(
                          "صور التحاليل الطبية",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "التقط صورة واضحة للحصول على تحليل فوري",
                          style: TextStyle(
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
                        children: const [
                          Icon(Icons.arrow_back, color: Color(0xFF1FB6A6), size: 16),
                          SizedBox(width: 4),
                          Text("عرض التفاصيل", style: TextStyle(color: Color(0xFF1FB6A6))),
                        ],
                      ),
                    ),
                    const Text(
                      "آخر تحليل",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                _buildResultCard("سكر الدم (Glucose)", "mg/dL 95", "طبيعي"),
                _buildResultCard("الهيموجلوبين", "g/dL 15.2", "طبيعي"),

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
                const Text(
                  "التنبيهات والتذكيرات",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                _buildReminderCard(
                  title: "موعد الدواء",
                  subtitle: "حان وقت تناول دواء الضغط - 4:00 مساءً",
                  icon: Icons.notifications_none,
                  color: const Color(0xFFC77800),
                  backgroundColor: const Color(0xFFFFFDF5),
                  borderColor: const Color(0xFFFFE082),
                ),
                const SizedBox(height: 12),
                _buildReminderCard(
                  title: "تذكير بالتحليل",
                  subtitle: "حان موعد إجراء تحليل السكر التراكمي (HbA1c)",
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

  Widget _buildResultCard(String title, String value, String status) {
    return Container(
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
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FFED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFB7EB8F)),
            ),
            child: Row(
              children: const [
                Text("طبيعي",
                    style: TextStyle(
                        color: Color(0xFF52C41A),
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 6),
                Icon(Icons.check, color: Color(0xFF52C41A), size: 16),
              ],
            ),
          ),
        ],
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