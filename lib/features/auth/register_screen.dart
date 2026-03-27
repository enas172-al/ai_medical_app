import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1FB6A6),

      body: SafeArea(
        child: SingleChildScrollView( // 🔥 حل مشكلة overflow
          child: Column(
            children: [

              SizedBox(height: 30),

              // 🧪 Logo
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.science,
                  color: Color(0xFF1FB6A6),
                  size: 45,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "labby",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                "رفيقك في رحلة الصحة",
                style: TextStyle(color: Colors.white70),
              ),

              SizedBox(height: 20),

              // 📦 Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // الاسم
                    Text("الاسم الكامل"),
                    SizedBox(height: 6),
                    TextField(
                      decoration: inputStyle("ادخل اسمك", Icons.person_outline),
                    ),

                    SizedBox(height: 15),

                    // الإيميل
                    Text("البريد الإلكتروني"),
                    SizedBox(height: 6),
                    TextField(
                      decoration: inputStyle("example@email.com", Icons.email_outlined),
                    ),

                    SizedBox(height: 15),

                    // كلمة المرور
                    Text("كلمة المرور"),
                    SizedBox(height: 6),
                    TextField(
                      obscureText: true,
                      decoration: inputStyle("********", Icons.lock_outline),
                    ),

                    SizedBox(height: 15),

                    // كود العائلة
                    Text("كود العائلة (اختياري)"),
                    SizedBox(height: 6),
                    TextField(
                      decoration: inputStyle("ادخل كود العائلة للربط", Icons.group_outlined),
                    ),

                    SizedBox(height: 25),

                    // زر إنشاء حساب
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
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: Text("إنشاء حساب"),
                      ),
                    ),

                    SizedBox(height: 15),

                    // رجوع لتسجيل الدخول
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "لديك حساب؟ تسجيل الدخول",
                          style: TextStyle(
                            color: Color(0xFF1FB6A6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}