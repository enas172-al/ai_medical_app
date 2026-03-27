import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      // 🧭 Bottom Navigation
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [

              // 🔝 Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("labby", style: TextStyle(fontWeight: FontWeight.bold)),
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
                "بحث عن التحاليل",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              Text(
                "اكتشف معاني التحاليل والقيم الطبيعية",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              // 🔍 Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: "ابحث عن تحليل...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Color(0xFFF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // 📋 List
              Expanded(
                child: ListView(
                  children: [
                    searchCard("سكر الدم", "Glucose"),
                    searchCard("الهيموجلوبين", "Hemoglobin"),
                    searchCard("الكوليسترول الكلي", "Total Cholesterol"),
                    searchCard("فيتامين د", "Vitamin D"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔎 Card
  Widget searchCard(String title, String sub) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [

          Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 5),
                Text(
                  "طبيعي",
                  style: TextStyle(color: Color(0xFF1FB6A6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}