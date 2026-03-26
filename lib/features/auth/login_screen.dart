import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF1FB6A6),
        body: SafeArea(
            child: Column(
                children: [

                SizedBox(height: 40),

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

            // اسم التطبيق
            Text(
              "labby",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 5),

            Text(
              "رفيقك في رحلة الصحة",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            SizedBox(height: 30),

            // 📦 Card
            Expanded(
                child: Container(
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

                  // عنوان
                  Center(
                  child: Text(
                  "تسجيل الدخول",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // البريد الإلكتروني
                Text("البريد الإلكتروني"),
                SizedBox(height: 6),
                TextField(
                  decoration: InputDecoration(
                    hintText: "example@email.com",
                    prefixIcon: Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 15),

                // كلمة المرور
                Text("كلمة المرور"),
                SizedBox(height: 6),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "********",
                    prefixIcon: Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // 🔘 زر الدخول
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1FB6A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text(
                        "دخول",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                ),

                      SizedBox(height: 15),

                      // 🔗 إنشاء حساب
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            "ليس لديك حساب؟ إنشاء حساب",
                            style: TextStyle(
                              color: Color(0xFF1FB6A6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
                ],
            ),
        ),
    );
  }
}