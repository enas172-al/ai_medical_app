import 'package:flutter/material.dart';
import '../notifications/notification_sheet.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),

      // 🧭 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF1FB6A6),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "السجل"),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: "الدواء"),
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

                // 🔝 Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => NotificationSheet(),
                                );
                              },
                              child: Icon(Icons.notifications_none),
                            ),
                            Positioned(
                              right: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: Text("4",
                                    style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.search),
                      ],
                    ),

                    Row(
                      children: [
                        Text("labby",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFF1FB6A6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.science, color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),

                SizedBox(height: 20),

                // 👋 Greeting
                Text(
                  "مرحباً أحمد 👋",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                Text(
                  "كيف حالك اليوم؟",
                  style: TextStyle(color: Colors.grey),
                ),

                SizedBox(height: 10),

                // ✨ Tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("✨ الذكاء الاصطناعي في الطب"),
                ),

                SizedBox(height: 20),

                // 📷 Scan Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1FB6A6), Color(0xFF1AA3A3)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [

                      Container(padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(Icons.camera_alt,
                            color: Color(0xFF1FB6A6), size: 30),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "صور التحاليل الطبية",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "التقط صورة واضحة للحصول على تحليل فوري",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // 📊 Last Result
                Text("آخر تحليل",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                SizedBox(height: 10),

                resultCard("سكر الدم (Glucose)", "95 mg/dL", Colors.green),
                resultCard("الهيموجلوبين", "15.2 g/dL", Colors.green),

                SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🧾 Result Card
  Widget resultCard(String title, String value, Color color) {
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
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(title),
              SizedBox(width: 10),
              Icon(Icons.check_circle, color: color),
            ],
          )
        ],
      ),
    );
  }

  // 🔔 Alert Card
  Widget alertCard(String title, String desc, Color bg, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: iconColor),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(desc),
              ],
            ),
          )
        ],
      ),
    );
  }
}