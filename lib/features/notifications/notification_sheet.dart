import 'package:flutter/material.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [

          // 🔝 Header
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF1FB6A6),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "الإشعارات",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // 📋 List
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(15),
              children: [

                notificationItem(
                  "موعد الدواء",
                  "حان وقت تناول دواء الضغط",
                  "منذ 5 دقائق",
                  Icons.medication,
                  Colors.orange,
                ),

                notificationItem(
                  "تذكير بالتحليل",
                  "حان موعد إجراء تحليل السكر التراكمي",
                  "منذ ساعة",
                  Icons.notifications,
                  Colors.blue,
                ),

                notificationItem(
                  "نتيجة جديدة",
                  "تم تحليل نتائجك بنجاح",
                  "منذ 3 ساعات",
                  Icons.check_circle,
                  Colors.green,
                ),

                SizedBox(height: 10),

                Center(
                  child: Text(
                    "عرض جميع الإشعارات",
                    style: TextStyle(color: Color(0xFF1FB6A6)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget notificationItem(
      String title, String desc, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [

          // icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          SizedBox(width: 10),

          // text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(desc),
                SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}