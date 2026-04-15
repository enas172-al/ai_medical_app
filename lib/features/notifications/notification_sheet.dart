import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/notifications_repository.dart';
import '../../core/models/app_notification_model.dart';
import 'all_notifications_screen.dart';

class NotificationSheet extends StatelessWidget {
  const NotificationSheet({super.key});

  String _friendlyError(Object? err) {
    if (err is FirebaseException) {
      if (err.code == 'permission-denied') {
        return 'ليس لديك صلاحية لعرض الإشعارات. تأكد من نشر قواعد Firestore.';
      }
      if (err.code == 'failed-precondition' && err.message != null && err.message!.toLowerCase().contains('index')) {
        return 'لازم تنشر فهارس Firestore (indexes) عشان الإشعارات تخدم.\n'
            'شغّل: firebase deploy --only firestore:indexes';
      }
    }
    return 'صار خطأ أثناء تحميل الإشعارات.';
  }

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
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnap) {
                final uid = authSnap.data?.uid;
                if (uid == null) {
                  return Center(child: Text("history_sign_in".tr()));
                }
                return StreamBuilder<List<AppNotificationModel>>(
                  stream: NotificationsRepository().watchForUser(uid, limit: 5),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            _friendlyError(snap.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    final list = snap.data ?? const <AppNotificationModel>[];
                    return ListView(
                      padding: const EdgeInsets.all(15),
                      children: [
                        if (list.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: Text("no_data_found".tr())),
                          )
                        else
                          ...list.map((n) => _notificationItemFromModel(context, n)),
                        const SizedBox(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AllNotificationsScreen()),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _notificationItemFromModel(BuildContext context, AppNotificationModel n) {
    final title = n.title;
    final desc = n.body;
    final time = n.createdAt.toIso8601String().split('T').first;
    final color = n.type == 'analysis'
        ? Colors.green
        : n.type == 'medication'
            ? Colors.orange
            : Colors.blue;
    final icon = n.type == 'analysis'
        ? Icons.check_circle
        : n.type == 'medication'
            ? Icons.medication
            : Icons.notifications;

    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          NotificationsRepository().markRead(n.id);
          final route = n.data['route'] as String?;
          if (route != null && route.isNotEmpty) {
            Navigator.pushNamed(context, route);
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
            color: color.withValues(alpha: 0.2),
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