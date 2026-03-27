import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      // 🧭 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // 🔝 Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "labby",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1FB6A6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.science, color: Colors.white),
                  )
                ],
              ),

              SizedBox(height: 20),

              // 🧾 Title
              Text(
                "سجل التحاليل",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),

              Text(
                "جميع تحاليلك السابقة في مكان واحد",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              // 🔘 Tabs
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text("الأحدث")),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFF1FB6A6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "جميع التحاليل",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // 📊 List
              Expanded(
                child: ListView(
                  children: [
                    historyCard("سكر الدم", "Glucose", "12", "20 مارس 2026"),
                    historyCard("الهيموجلوبين", "Hemoglobin", "8", "20 مارس 2026"),
                    historyCard("الكوليسترول", "Cholesterol", "6", "18 مارس 2026"),
                    historyCard("فيتامين د", "Vitamin D", "4", "15 مارس 2026"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧾 Card
  Widget historyCard(String title, String sub, String count, String date) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [

          // سهم
          Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),

          SizedBox(width: 10),

          // دائرة العدد
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFE6F7F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                count,
                style: TextStyle(
                    color: Color(0xFF1FB6A6),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SizedBox(width: 15),

          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Text("آخر تحديث: $date",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
