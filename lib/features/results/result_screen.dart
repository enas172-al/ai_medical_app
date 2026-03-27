import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Color(0xFF1FB6A6),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "الدواء"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "السجل"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "الملف"),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🔙 رجوع
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back),
                ),

                SizedBox(height: 10),

                Text(
                  "نتائج التحاليل",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                Text("20 مارس 2026", style: TextStyle(color: Colors.grey)),

                SizedBox(height: 20),

                // 🔘 أزرار
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.share),
                        label: Text("مشاركة"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.save),
                        label: Text("حفظ"),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // 🧪 تحليل واحد بالتفصيل
                resultDetailCard(),

                SizedBox(height: 20),

                resultItem("الهيموجلوبين", "15.2", "g/dL", Colors.green, "طبيعي"),
                resultItem("الكوليسترول", "220", "mg/dL", Colors.red, "مرتفع"),
                resultItem("فيتامين د", "18", "ng/mL", Colors.orange, "منخفض"),
                resultItem("خلايا الدم البيضاء", "7.5", "µL", Colors.green, "طبيعي"),

                SizedBox(height: 20),

                // 📌 ملاحظة
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "ملاحظة: هذه النتائج تم تحليلها بواسطة الذكاء الاصطناعي. يُرجى استشارة الطبيب المختص.",
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

  // 🔥 الكارت الكبير
  Widget resultDetailCard() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("95 mg/dL", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text("سكر الدم"),
              SizedBox(width: 10),
              Icon(Icons.check_circle, color: Colors.green),
            ],
          )
        ],
      ),

      SizedBox(height: 15),Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("المعدل الطبيعي: 70-100 mg/dL"),
          ),

          SizedBox(height: 15),

          Text("التفسير", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("مستوى السكر طبيعي ويدل على صحة جيدة."),

          SizedBox(height: 15),

          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF1FB6A6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("حافظ على نظام غذائي صحي وممارسة الرياضة."),
          ),
        ],
      ),
    );
  }

  // 🧾 العناصر الصغيرة
  Widget resultItem(String name, String value, String unit, Color color, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$value $unit"),
          Row(
            children: [
              Text(name),
              SizedBox(width: 10),
              Icon(Icons.circle, color: color, size: 10),
            ],
          )
        ],
      ),
    );
  }
}