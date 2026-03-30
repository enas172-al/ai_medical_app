import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data =
    ModalRoute.of(context)!.settings.arguments as Map?;

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
                      "نتائج تحليل الصور",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              /// 📊 Card النتائج
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ListView(
                    children: [

                      _buildItem("الكالسيوم", "9.4", Colors.green),
                      _buildItem("كرات الدم الحمراء", "5.2", Colors.orange),
                      _buildItem("حجم كرات الدم", "99.7", Colors.green),
                      _buildItem("الهيموجلوبين", "18.2", Colors.red),
                      _buildItem("الدهون الثلاثية", "150", Colors.orange),
                      _buildItem("ضغط الدم", "120/80", Colors.green),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ✨ ملاحظة (تعطي جو 🔥)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FB6A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "💡 ملاحظة: بعض النتائج تحتاج متابعة طبية، ننصح بمراجعة الطبيب.",
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

  /// 🔥 عنصر النتيجة (محسن)
  Widget _buildItem(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(16),
    ),
      child: Row(
        children: [

          /// 🔘 Status circle
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 12),

          /// 🔢 Value
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          const Spacer(),

          /// 🧾 Title
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}