import 'package:flutter/material.dart';
import 'home_detail_screen.dart';
import 'package:ai_medical_app/features/scan/scan_screen.dart'; // 🔥 مهم

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),

        body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                /// 👋 ترحيب
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

              /// ✨ AI Tag
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

              /// 📷 Scan Card (🔥 تم التعديل هنا)
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

              /// 📊 Header
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeDetailScreen(),
                        ),
                      );
                    },
              child: const Text(
                "عرض التفاصيل",
                style: TextStyle(color: Color(0xFF1FB6A6)),
              ),),

                    const Text(
                      "آخر تحليل",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
              ),

                  const SizedBox(height: 10),

                  /// 🧪 Cards
                  _buildCard("سكر الدم", "95", "mg/dL", "طبيعي"),
                  _buildCard("الهيموجلوبين", "15.2", "g/dL", "طبيعي"),
                  _buildCard("الكوليسترول", "220", "mg/dL", "مرتفع"),
                ],
              ),
            ),
        ),
    );
  }

  /// 🔥 Card
  Widget _buildCard(
      String title, String value, String unit, String status) {
    Color color;

    switch (status) {
      case "طبيعي":
        color = Colors.green;
        break;
      case "مرتفع":
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(unit,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: color),
                ),
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }
}