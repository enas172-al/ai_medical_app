import 'package:flutter/material.dart';
import 'analysis_detail_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// 🔥 Mock Data (محدثة لتطابق البيانات الموحدة)
    final results = [
      {
        "name": "السكر الصائم",
        "value": "95",
        "unit": "mg/dL",
        "status": "normal",
        "icon": Icons.bolt,
        "interpretation": "مستوى السكر في الدم ضمن النطاق الطبيعي للصائم.",
        "advice": "حافظ على نظامك الغذائي المتوازن."
      },
      {
        "name": "الهيموجلوبين",
        "value": "15.2",
        "unit": "g/dL",
        "status": "normal",
        "icon": Icons.water_drop_outlined,
        "interpretation": "نسبة الهيموجلوبين جيدة جداً، مما يشير إلى عدم وجود فقر دم.",
        "advice": "استمر في تناول الأغذية الغنية بالحديد."
      },
      {
        "name": "الكوليسترول",
        "value": "220",
        "unit": "mg/dL",
        "status": "high",
        "icon": Icons.warning_amber_rounded,
        "interpretation": "ارتفاع بسيط في مستوى الكوليسترول الكلي.",
        "advice": "ينصح بتقليل الدهون المشبعة وممارسة الرياضة ومراجعة الطبيب."
      },
      {
        "name": "فيتامين D",
        "value": "18",
        "unit": "ng/mL",
        "status": "low",
        "icon": Icons.wb_sunny_outlined,
        "interpretation": "نقص في مستويات فيتامين د.",
        "advice": "ينصح بالتعرض للشمس وتناول المكملات الغذائية بعد استشارة الطبيب."
      },
      {
        "name": "خلايا الدم البيضاء",
        "value": "7.5",
        "unit": "x10^9/L",
        "status": "normal",
        "icon": Icons.biotech_outlined,
        "interpretation": "عدد خلايا الدم البيضاء سليم، مما يشير إلى عدم وجود التهابات حالية.",
        "advice": "جهاز المناعة يعمل بشكل جيد."
      },
      {
        "name": "ضغط الدم",
        "value": "120/80",
        "unit": "mmHg",
        "status": "normal",
        "icon": Icons.water_drop_outlined,
        "interpretation": "ضغط الدم ضمن المعدل المثالي.",
        "advice": "حافظ على ممارسة النشاط البدني وادارة القلق."
      }
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                /// 🔙 Back + Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        const Text(
                          "labby",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset('assets/images/logo.png', width: 38, height: 38),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// 🧪 Title
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "نتائج التحاليل",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "20 مارس 2026",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔘 Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton("حفظ", Icons.save_alt_outlined),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildActionButton("مشاركة", Icons.share_outlined),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// 📊 النتائج
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return _buildItem(
                        context: context,
                        title: item["name"] as String,
                        value: item["value"] as String,
                        unit: item["unit"] as String,
                        statusKey: item["status"] as String,
                        icon: item["icon"] as IconData,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                /// 💡 ملاحظة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FB6A6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "💡 ملاحظة: هذه النتائج تم تحليلها بواسطة الذكاء الاصطناعي، يرجى مراجعة الطبيب المختص للحصول على تقييم دقيق ومتابعة طبية.",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF1FB6A6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1F2937)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "high":
        return const Color(0xFFF5222D);
      case "low":
        return const Color(0xFFFAAD14);
      default:
        return const Color(0xFF52C41A);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case "high":
        return const Color(0xFFFFF1F0);
      case "low":
        return const Color(0xFFFFF7E6);
      default:
        return const Color(0xFFF6FFED);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "high":
        return "مرتفع";
      case "low":
        return "منخفض";
      default:
        return "طبيعي";
    }
  }

  Widget _buildItem({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required String statusKey,
    required IconData icon,
  }) {
    final statusColor = _getStatusColor(statusKey);
    final statusBg = _getStatusBg(statusKey);
    final statusText = _getStatusText(statusKey);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisDetailScreen(
              name: title,
              value: value,
              unit: unit,
              status: statusText,
              date: "2026-03-20",
              statusColor: statusColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
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
          children: [
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  unit,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  title == "السكر الصائم" ? "Glucose" : 
                  title == "الهيموجلوبين" ? "Hemoglobin" :
                  title == "الكوليسترول" ? "Cholesterol" :
                  title == "فيتامين D" ? "Vitamin D" : 
                  title == "ضغط الدم" ? "Blood Pressure" : "White Blood Cells",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}