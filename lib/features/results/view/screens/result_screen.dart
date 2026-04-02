import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {

    /// 🔥 Mock Data (مؤقت حتى تربطي AI)
    final results = [
      {
        "name": "الهيموجلوبين",
        "value": "18.2",
        "status": "high",
        "interpretation": "ارتفاع في نسبة الهيموجلوبين وقد يدل على نقص السوائل أو مشاكل في الدم",
        "advice": "ينصح بشرب كميات كافية من الماء ومراجعة الطبيب"
      },
      {
        "name": "السكر",
        "value": "150",
        "status": "high",
        "interpretation": "ارتفاع مستوى السكر في الدم",
        "advice": "تقليل السكريات ومتابعة الطبيب"
      },
      {
        "name": "الكالسيوم",
        "value": "9.4",
        "status": "normal",
        "interpretation": "المستوى طبيعي",
        "advice": "استمر على نظامك الغذائي"
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              /// 🔙 Back
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 10),

              /// 🧪 Logo + Title
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1FB6A6), Color(0xFF14917E)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.science,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "نتائج التحليل الذكي",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 📊 النتائج
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];

                    return _buildItem(
                      title: item["name"] ?? "غير معروف",
                      value: item["value"] ?? "-",
                      color: _getColor(item["status"]!),
                      status: _getStatusText(item["status"] ?? "normal"),
                      interpretation: item["interpretation"] ?? "لا يوجد تفسير",
                      advice: item["advice"] ?? "لا توجد نصيحة",
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              /// 💡 ملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FB6A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "💡 هذه النتائج مقدمة بواسطة الذكاء الاصطناعي، ننصح بمراجعة الطبيب للتأكيد.",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF1FB6A6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔴🟡🟢 اللون
  Color _getColor(String status) {
    switch (status) {
      case "high":
        return Colors.red;
      case "low":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  /// 🏷️ النص
  String _getStatusText(String status) {
    switch (status) {
      case "high":
        return "🔴 مرتفع";
      case "low":
        return "🟡 منخفض";
      default:
        return "🟢 طبيعي";
    }
  }

  /// 🔥 Card
  Widget _buildItem({
    required String title,
    required String value,
    required Color color,
    required String status,
    required String interpretation,
    required String advice,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("🧠 $interpretation"),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1FB6A6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("💡 $advice"),
          ),
        ],
      ),
    );
  }
}