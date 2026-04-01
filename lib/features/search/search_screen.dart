import 'package:flutter/material.dart';
import '../../core/widgets/custom_app_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        /// 🔹 AppBar
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

                /// 🧾 Title
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

                /// 🔍 Search Box
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
                      _buildTestCard("سكر الدم", "Glucose", "السكريات"),
                      _buildTestCard("الهيموجلوبين", "Hemoglobin", "الدم"),
                      _buildTestCard("الكوليسترول الكلي", "Total Cholesterol", "الدهون"),
                      _buildTestCard("فيتامين د", "Vitamin D", "الفيتامينات"),
                      _buildTestCard("الكرياتينين", "Creatinine", "الكلى"),
                      _buildTestCard("إنزيم الكبد ALT", "ALT (SGPT)", "الكبد"),
                      _buildTestCard("خلايا الدم البيضاء", "White Blood Cells (WBC)", "الدم"),
                      _buildTestCard("الصفائح الدموية", "Platelets", "الدم"),
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
  Widget _buildTestCard(String title, String subtitle, String category) {
    return Container(
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
    );
  }
}