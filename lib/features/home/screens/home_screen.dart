import 'package:flutter/material.dart';
import 'package:ai_medical_app/features/results/view/screens/result_screen.dart';
import '../../results/view/screens/result_screen.dart';
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
                "مرحباً أحمد",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              const Text(
                "كيف حالك اليوم؟",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.right,
              ),

              const SizedBox(height: 20),

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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),

              const SizedBox(height: 20),

              /// 📷 Scan Card
              GestureDetector(
                onTap: () {},
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
                      Icon(Icons.camera_alt, color: Colors.white, size: 36),
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

              /// 📊 العنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// 🔹 زر التفاصيل (FIX: حذف const)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "عرض التفاصيل",
                      style: TextStyle(
                        color: Color(0xFF1FB6A6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Text(
                    "آخر تحليل",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// 🧪 الكروت
              _buildResultCard(
                title: "سكر الدم",
                value: "95",
                unit: "mg/dL",
                status: "طبيعي",
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                title: "الهيموجلوبين",
                value: "15.2",
                unit: "g/dL",
                status: "طبيعي",
              ),

              const SizedBox(height: 12),

              _buildResultCard(
                title: "الكوليسترول",
                value: "220",
                unit: "mg/dL",
                status: "مرتفع",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 كارت مطابق لتصميم Labby
  Widget _buildResultCard({
    required String title,
    required String value,
    required String unit,
    required String status,
  }) {
    Color getColor() {
      switch (status) {
        case "طبيعي":
          return const Color(0xFF2E7D32);
        case "مرتفع":
          return const Color(0xFFD32F2F);
        case "منخفض":
          return const Color(0xFFF57C00);
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          /// 🔹 القيمة (يسار)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          /// 🔹 العنوان + الحالة (يمين)
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: getColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

