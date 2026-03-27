import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';

class MedicationScreen extends StatelessWidget {
  const MedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF7F9FB),

        // 🧭 Bottom Navigation
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Color(0xFF1FB6A6),
          unselectedItemColor: Colors.grey,

          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else if (index == 1) {
              // نفس الصفحة
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            }
          },

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
                  "الأدوية والمكملات",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                Text(
                  "تتبع مواعيد أدويتك ومكملاتك الغذائية",
                  style: TextStyle(color: Colors.grey),
                ),

                SizedBox(height: 20),

                // ➕ زر إضافة
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1FB6A6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => AddMedicationSheet(),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text("إضافة دواء جديد"),
                  ),
                ),

                SizedBox(height: 20),

                // 📋 List
                Expanded(
                  child: ListView(
                      children: [
                      medCard("أسبرين", "100 ملغ", "08:00 صباحاً", Colors.blue),
                  medCard("ميتفورمين", "500 ملغ", "12:00 ظهراً", Colors.purple),medCard("فيتامين د", "1000 وحدة", "09:00 صباحاً", Colors.orange),
                      ],
                  ),
                ),
                  ],
                ),
            ),
        ),
    );
  }

  // 💊 Card
  Widget medCard(String name, String dose, String time, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [

          Icon(Icons.delete, color: Colors.red),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(dose),
                SizedBox(height: 5),
                Text(time, style: TextStyle(color: Colors.grey)),
                Text("يومياً", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.link, color: color),
          ),
        ],
      ),
    );
  }
}

class AddMedicationSheet extends StatelessWidget {
  const AddMedicationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                  Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close),
                  ),
                ),

                SizedBox(height: 10),

                Center(
                  child: Text(
                    "إضافة دواء جديد",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Text("اسم الدواء"),
                SizedBox(height: 6),
                inputField("مثال: أسبرين"),

                SizedBox(height: 15),

                Text("الجرعة"),
                SizedBox(height: 6),
                inputField("مثال: 100 ملغ"),

                SizedBox(height: 15),

                Text("الوقت"),
                SizedBox(height: 6),
                inputField("--:--", icon: Icons.access_time),

                SizedBox(height: 15),

                Text("التكرار"),
                SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(border: InputBorder.none),
                    items: ["يومياً", "أسبوعياً"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {},
                  ),
                ),

                SizedBox(height: 25),

                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1FB6A6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                            ),
                        ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("إضافة"),
                    ),
                ),
                  ],
                ),
            ),
        ),
    );
  }

  Widget inputField(String hint, {IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}