import 'package:flutter/material.dart';

import '../../core/widgets/custom_app_bar.dart';

class AnalysisDetailsScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final String normalRange;
  final String highText;
  final String lowText;
  final String? simplifiedExplanation;
  final String? referenceText;
  final String? sourceUrl;

  const AnalysisDetailsScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.normalRange,
    required this.highText,
    required this.lowText,
    this.simplifiedExplanation,
    this.referenceText,
    this.sourceUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: const CustomAppBar(
          title: "",
          showBack: true,
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                /// 🧾 Title
                const Text(
                  "بحث عن التحاليل",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                /// 📋 Subtitle
                const Text(
                  "اكتشف معاني التحاليل والقيم الطبيعية",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 16),
                /// 🔹 الكرت الأخضر
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF39D6C6),
                          Color(0xFF14B8A6),
                          Color(0xFF098E8D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                    ),

                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if ((simplifiedExplanation ?? '').trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 6),
                            Text(
                              "شرح مبسط",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(simplifiedExplanation!.trim()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                /// 🔹 المعدل الطبيعي
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.circle, size: 8, color: Colors.green),
                          SizedBox(width: 6),
                          Text("المعدل الطبيعي"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        normalRange,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "الوحدة حسب التحليل",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if ((referenceText ?? '').trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.list_alt, color: Colors.black54),
                            SizedBox(width: 6),
                            Text(
                              "تفاصيل المعدل الطبيعي",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(referenceText!.trim()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                /// 🔹 الارتفاع
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.trending_up, color: Colors.red),
                          SizedBox(width: 6),
                          Text(
                            "ماذا يعني الارتفاع؟",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(highText.trim().isEmpty ? "غير متوفر" : highText),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// 🔹 الانخفاض
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.trending_down, color: Colors.orange),
                          SizedBox(width: 6),
                          Text(
                            "ماذا يعني الانخفاض؟",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(lowText.trim().isEmpty ? "غير متوفر" : lowText),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if ((sourceUrl ?? '').trim().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sourceUrl!.trim(),
                            style: const TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                /// 🔹 تنبيه
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "تنبيه: هذه المعلومات للإرشاد فقط ولا تغني عن استشارة الطبيب.",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}