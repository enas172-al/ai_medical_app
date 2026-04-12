import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../core/theme/app_colors.dart';

final List<Map<String, dynamic>> allNotifications = [
  {
    "title": "موعد الدواء",
    "subtitle": "حان وقت تناول دواء الضغط",
    "time": "منذ 5 دقائق",
    "icon": Icons.medication,
    "color": Colors.orange,
  },
  {
    "title": "تذكير بالتحليل",
    "subtitle": "حان موعد إجراء تحليل السكر التراكمي",
    "time": "منذ ساعة",
    "icon": Icons.notifications,
    "color": Colors.blue,
  },
  {
    "title": "نتيجة جديدة",
    "subtitle": "تم تحليل نتائجك بنجاح",
    "time": "منذ 3 ساعات",
    "icon": Icons.check_circle,
    "color": Colors.green,
  },
  {
    "title": "نتيجة جديدة",
    "subtitle": "تم تحليل نتائجك بنجاح",
    "time": "منذ 3 ساعات",
    "icon": Icons.check_circle,
    "color": Colors.green,
  },
  {
    "title": "نتيجة جديدة",
    "subtitle": "تم تحليل نتائجك بنجاح",
    "time": "منذ 3 ساعات",
    "icon": Icons.check_circle,
    "color": Colors.green,
  },
  {
    "title": "نتيجة جديدة",
    "subtitle": "تم تحليل نتائجك بنجاح",
    "time": "منذ 3 ساعات",
    "icon": Icons.check_circle,
    "color": Colors.green,
  },
  {
    "title": "نتيجة جديدة",
    "subtitle": "تم تحليل نتائجك بنجاح",
    "time": "منذ 3 ساعات",
    "icon": Icons.check_circle,
    "color": Colors.green,
  },

];


class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
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
              color: AppColors.primary,
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
                  "medication_time".tr(),
                  "bp_med_reminder_simple".tr(),
                  "since_5_minutes".tr(),
                  Icons.medication,
                  Colors.orange,
                ),

                notificationItem(
                  context,
                  "test_reminder".tr(),
                  "hba1c_reminder_simple".tr(),
                  "since_1_hour".tr(),
                  Icons.notifications,
                  Colors.blue,
                ),

                notificationItem(
                  context,
                  "new_result".tr(),
                  "analysis_success".tr(),
                  "since_3_hours".tr(),
                  Icons.check_circle,
                  Colors.green,
                ),

                const SizedBox(height: 10),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllNotificationsScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "view_all_notifications".tr(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
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
    );
  }

  //  عنصر الإشعار
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


          if (title == "new_result".tr()) {
            Navigator.pushNamed(context, '/result');
          } else if (title == "test_reminder".tr()) {
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

class AllNotificationsScreen extends StatelessWidget {
  const AllNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("all_notifications".tr()),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: allNotifications.length,
        itemBuilder: (context, index) {
          final n = allNotifications[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: n["color"].withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(n["icon"], color: n["color"]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(n["subtitle"]),
                      const SizedBox(height: 4),
                      Text(
                        n["time"],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}