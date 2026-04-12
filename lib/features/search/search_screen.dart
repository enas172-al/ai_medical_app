import 'package:flutter/material.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../analysis/analysis_details_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        /// AppBar
        appBar: const CustomAppBar(
          title: "",
          showBack: true,
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 10),
                const SizedBox(height: 10),

                ///  Title
                const Text(
                  "بحث عن التحاليل",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 8),

                /// 📋 Subtitle
                const Text(
                  "اكتشف معاني التحاليل والقيم الطبيعية",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                ///  Search Box
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const TextField(
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: "ابحث عن تحليل...",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// 📋 List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [

                      _buildTestCard(
                        context,
                        "سكر الدم",
                        "Glucose",
                        "السكريات",
                        "70-100 mg/dL",
                        "قد يشير إلى مرض السكري أو مقاومة الأنسولين.",
                        "قد يدل على انخفاض السكر ويحتاج تدخل سريع.",
                      ),

                      _buildTestCard(
                        context,
                        "الهيموجلوبين",
                        "Hemoglobin",
                        "الدم",
                        "13-17 g/dL",
                        "قد يدل على الجفاف أو أمراض الدم.",
                        "قد يشير إلى فقر الدم (أنيميا).",
                      ),

                      _buildTestCard(
                        context,
                        "الكوليسترول الكلي",
                        "Total Cholesterol",
                        "الدهون",
                        "< 200 mg/dL",
                        "يزيد خطر أمراض القلب.",
                        "نادرًا ما يكون منخفض ويشير لسوء تغذية.",
                      ),

                      _buildTestCard(
                        context,
                        "فيتامين د",
                        "Vitamin D",
                        "الفيتامينات",
                        "20-50 ng/mL",
                        "قد يسبب ضعف العظام.",
                        "قد يؤدي إلى مشاكل في امتصاص الكالسيوم.",
                      ),

                      _buildTestCard(
                        context,
                        "الكرياتينين",
                        "Creatinine",
                        "الكلى",
                        "0.6-1.3 mg/dL",
                        "قد يدل على ضعف وظائف الكلى.",
                        "نادراً ما يكون منخفض.",
                      ),

                      _buildTestCard(
                        context,
                        "إنزيم الكبد ALT",
                        "ALT (SGPT)",
                        "الكبد",
                        "7-56 U/L",
                        "قد يشير إلى التهاب الكبد.",
                        "غالباً لا يكون له دلالة مهمة.",
                      ),

                      _buildTestCard(
                        context,
                        "خلايا الدم البيضاء",
                        "WBC",
                        "الدم",
                        "4,000-11,000 /µL",
                        "قد يدل على وجود عدوى.",
                        "قد يشير إلى ضعف المناعة.",
                      ),

                      _buildTestCard(
                        context,
                        "الصفائح الدموية",
                        "Platelets",
                        "الدم",
                        "150,000-450,000 /µL",
                        "قد يسبب جلطات.",
                        "قد يسبب نزيف.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔎 Card
  Widget _buildTestCard(
      BuildContext context,
      String title,
      String subtitle,
      String category,
      String normalRange,
      String highText,
      String lowText,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisDetailsScreen(
              title: title,
              subtitle: subtitle,
              category: category,
              normalRange: normalRange,
              highText: highText,
              lowText: lowText,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF1FB6A6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back,
              color: Colors.grey,
              size: 24,
              textDirection: TextDirection.ltr,
            ),
          ],
        ),
      ),
    );
  }
}