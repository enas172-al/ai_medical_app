import 'package:flutter/material.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [

              SizedBox(height: 20),

              // 🧠 Logo
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFF1FB6A6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.favorite, color: Colors.white),
              ),

              SizedBox(height: 15),

              Text(
                "إعداد الملف الشخصي",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "أكمل معلوماتك الشخصية للبدء",
                style: TextStyle(color: Colors.grey),
              ),

              SizedBox(height: 20),

              // 📦 Card
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [

                    // الاسم
                    input("الاسم الكامل", "أدخل اسمك الكامل"),

                    SizedBox(height: 15),

                    // الجنس
                    Row(
                      children: [
                        Expanded(child: genderButton("ذكر")),
                        SizedBox(width: 10),
                        Expanded(child: genderButton("أنثى")),
                      ],
                    ),

                    SizedBox(height: 15),

                    input("الطول (سم)", "مثال: 170"),
                    SizedBox(height: 15),

                    input("الوزن (كجم)", "مثال: 70"),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // زر متابعة
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1FB6A6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text("متابعة"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 Input
  Widget input(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(label),
        ),
        SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // 🔘 Gender Button
  Widget genderButton(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(text)),
    );
  }
}