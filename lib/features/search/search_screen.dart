import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      // 🔙 AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("بحث", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🧾 Title
              Text(
                "ابحث عن التحاليل 🔍",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              Text(
                "اكتب اسم التحليل لمعرفة التفاصيل",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              // 🔍 Search Box (🔥 مطور)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "مثال: سكر الدم",
                    prefixIcon: Icon(Icons.search, color: Color(0xFF1FB6A6)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(15),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ✨ Suggested Title
              Text(
                "تحاليل شائعة",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              // 📋 List
              Expanded(
                child: ListView(
                  children: [
                    searchCard("سكر الدم", "Glucose", Icons.water_drop, Colors.blue),
                    searchCard("الهيموجلوبين", "Hemoglobin", Icons.bloodtype, Colors.red),
                    searchCard("الكوليسترول", "Cholesterol", Icons.favorite, Colors.orange),
                    searchCard("فيتامين د", "Vitamin D", Icons.wb_sunny, Colors.amber),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔎 Card مطور
  Widget searchCard(String title, String sub, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
          children: [

      // 🔥 Icon Circle
      Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    ),

    SizedBox(width: 15),

    // 🧾 Text
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    Text(sub, style: TextStyle(color: Colors.grey)),
    SizedBox(height: 5),
    Text(
    "القيم الطبيعية متوفرة",
    style: TextStyle(
    color: Color(0xFF1FB6A6),
    fontSize: 12,),
    ),
    ],
    ),
    ),

            // ➡️ Arrow
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
      ),
    );
  }
}