import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 20),

                // 👤 User Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1FB6A6), Color(0xFF17A2A2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            color: Color(0xFF1FB6A6)),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "أحمد محمد",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ahmed@example.com",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 📄 Info Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      Text(
                        "المعلومات الشخصية",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: 15),

                      infoRow("الاسم الكامل", "أحمد محمد", Icons.person),
                      infoRow("البريد الإلكتروني", "ahmed@example.com", Icons.email),
                      infoRow("تاريخ الميلاد", "15 يناير 1990", Icons.calendar_today),
                      infoRow("الجنس", "ذكر", Icons.wc),

                    ],
                  ),
                ),

                SizedBox(height: 20), // 👈 مهم
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧾 Row
  Widget infoRow(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 3),
                Text(value,
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFE6F7F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Color(0xFF1FB6A6)),
          ),
        ],
      ),
    );
  }
}