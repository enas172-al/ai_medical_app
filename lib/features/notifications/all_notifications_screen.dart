import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/models/app_notification_model.dart';
import '../../core/services/notifications_repository.dart';

class AllNotificationsScreen extends StatelessWidget {
  const AllNotificationsScreen({super.key});

  String _friendlyError(Object? err) {
    if (err is FirebaseException) {
      if (err.code == 'permission-denied') {
        return 'ليس لديك صلاحية لعرض الإشعارات. تأكد من نشر قواعد Firestore.';
      }
      // Firestore often throws this when a composite index is missing.
      if (err.code == 'failed-precondition' && err.message != null && err.message!.toLowerCase().contains('index')) {
        return 'لازم تنشر فهارس Firestore (indexes) عشان صفحة الإشعارات تخدم.\n'
            'شغّل: firebase deploy --only firestore:indexes';
      }
    }
    return 'صار خطأ أثناء تحميل الإشعارات. حاول مرة ثانية.';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("all_notifications".tr()),
          actions: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snap) {
                final uid = snap.data?.uid;
                if (uid == null) return const SizedBox.shrink();
                return Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await NotificationsRepository().markAllRead(uid);
                      },
                      child: Text(
                        "reset".tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnap) {
            final uid = authSnap.data?.uid;
            if (uid == null) {
              return Center(child: Text("history_sign_in".tr()));
            }

            return StreamBuilder<List<AppNotificationModel>>(
              stream: NotificationsRepository().watchForUser(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  final msg = _friendlyError(snap.error);
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(msg, textAlign: TextAlign.center),
                    ),
                  );
                }

                final list = snap.data ?? const <AppNotificationModel>[];
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("no_data_found".tr(), textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final n = list[index];
                    return _NotificationTile(n: n);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel n;
  const _NotificationTile({required this.n});

  @override
  Widget build(BuildContext context) {
    final color = n.type == 'analysis'
        ? Colors.green
        : n.type == 'medication'
            ? Colors.orange
            : Colors.blue;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await NotificationsRepository().markRead(n.id);
        final route = n.data['route'] as String?;
        if (route != null && route.isNotEmpty && context.mounted) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.grey.shade100 : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                n.type == 'analysis'
                    ? Icons.check_circle
                    : n.type == 'medication'
                        ? Icons.medication
                        : Icons.notifications,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

