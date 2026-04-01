import 'package:flutter/material.dart';
import 'home_detail_screen.dart';
import 'package:ai_medical_app/features/scan/scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),

        body:
    Directionality(
    textDirection: TextDirection.rtl,
    child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                ///  ترحيب
                const Text(
                "مرحباً أحمد 👋",
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "✨ الذكاء الاصطناعي في الطب",
                  style: TextStyle(
                    color: Color(0xFF1FB6A6),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ///  Scan Card
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    builder: (_) => const ScanScreen(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1FB6A6), Color(0xFF14917E)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.camera_alt,
                          color: Colors.white, size: 36),
                      SizedBox(height: 12),
                      Text(
                        "صور التحاليل الطبية",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
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

              const SizedBox(height: 24),

              const SizedBox(height: 24),


              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("آخر تحليل", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeDetailScreen()));
                          },
                          child: Row(
                            children: const [
                              Text("عرض التفاصيل", style: TextStyle(color: Color(0xFF1FB6A6), fontWeight: FontWeight.bold, fontSize: 13)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_back, color: Color(0xFF1FB6A6), size: 14, textDirection: TextDirection.ltr),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Items
                    _buildLatestTestItem("سكر الدم (Glucose)", "95", "mg/dL", "طبيعي"),
                    const SizedBox(height: 12),
                    _buildLatestTestItem("الهيموجلوبين", "15.2", "g/dL", "طبيعي"),
                    const SizedBox(height: 16),
                    // Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // In RTL, end is Left
                      children: const [
                        Text("20 مارس 2026", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ///  التنبيهات والتذكيرات
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // RTL start is right
                children: const [
                  Text("التنبيهات والتذكيرات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              // Yellow reminder
              _buildReminderCard(
                title: "موعد الدواء",
                subtitle: "حان وقت تناول دواء الضغط - 4:00 مساءً",
                icon: Icons.notifications_none,
                color: const Color(0xFFC77800), // Dark Amber
                backgroundColor: const Color(0xFFFFFDF5),
                borderColor: const Color(0xFFFFE082),
              ),
              const SizedBox(height: 12),
              
              // Blue reminder
              _buildReminderCard(
                title: "تذكير بالتحليل",
                subtitle: "حان موعد إجراء تحليل السكر التراكمي (HbA1c)",
                icon: Icons.notifications_none,
                color: const Color(0xFF1565C0), // Dark Blue
                backgroundColor: const Color(0xFFF0F7FF),
                borderColor: const Color(0xFFBBDEFB),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    )
    );
  }

  // Helper for Latest Test Item
  Widget _buildLatestTestItem(String title, String value, String unit, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Right Side (Title & Value) in RTL
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(unit, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold, height: 1.5)),
                ],
              ),
            ],
          ),
          // Left Side (Badge) in RTL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade100)
            ),
            child: Row(
              children: [
                const Text("طبيعي", style: TextStyle(color: Color(0xFF4CAF50), fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                const Icon(Icons.check, color: Color(0xFF4CAF50), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Reminder Cards
  Widget _buildReminderCard({required String title, required String subtitle, required IconData icon, required Color color, required Color backgroundColor, required Color borderColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Icon on Right (RTL start)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          // Text
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