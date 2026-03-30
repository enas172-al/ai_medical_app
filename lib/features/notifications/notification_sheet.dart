import 'package:flutter/material.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [

          // 🔝 Header
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xFF1FB6A6),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "الإشعارات",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // 📋 List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [

                notificationItem(
                  context,
                  "موعد الدواء",
                  "حان وقت تناول دواء الضغط",
                  "منذ 5 دقائق",
                  Icons.medication,
                  Colors.orange,
                ),

                notificationItem(
                  context,
                  "تذكير بالتحليل",
                  "حان موعد إجراء تحليل السكر التراكمي",
                  "منذ ساعة",
                  Icons.notifications,
                  Colors.blue,
                ),

                notificationItem(
                  context,
                  "نتيجة جديدة",
                  "تم تحليل نتائجك بنجاح",
                  "منذ 3 ساعات",
                  Icons.check_circle,
                  Colors.green,
                ),

                const SizedBox(height: 10),

                const Center(
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

  // 🔥 عنصر الإشعار
  Widget notificationItem(
      BuildContext context,
      String title,
      String desc,
      String time,
      IconData icon,
      Color color,
      ) {
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {

          /// 🔥 إصلاح التنقل
          if (title == "نتيجة جديدة") {
            Navigator.pushNamed(context, '/result'); // ✅ صح
          } else if (title == "تذكير بالتحليل") {
            Navigator.pushNamed(context, '/history');
          } else {
            Navigator.pushNamed(context, '/home');
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: Row(
              children: [

          // 🔘 Icon
          Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),

        const SizedBox(width: 10),

        // 📝 Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),Text(desc),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
              ],
          ),
        ),
    );
  }
}