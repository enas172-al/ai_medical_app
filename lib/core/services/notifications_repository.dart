import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/app_notification_model.dart';
import 'email_webhook_service.dart';

class NotificationsRepository {
  NotificationsRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final EmailWebhookService _email = EmailWebhookService();

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('notifications');

  bool _isHidden(AppNotificationModel n) {
    if (n.isPeriodicSetupFeedItem) return true;
    // Hide legacy test notifications that were accidentally created earlier.
    final t = n.title.trim();
    final b = n.body.trim();
    if (t == 'Labby' && (b == 'تم إنشاء إشعار.' || b == 'Notification created.')) return true;
    return false;
  }

  Future<int> deleteLegacyTestNotifications(String userId) async {
    // Deletes only the old test notifications that were created earlier.
    // Safe: won't touch real notifications.
    final snap = await _col.where('userId', isEqualTo: userId).get();
    WriteBatch batch = _db.batch();
    var deleted = 0;
    for (final d in snap.docs) {
      final n = AppNotificationModel.fromDoc(d);
      final t = n.title.trim();
      final b = n.body.trim();
      final isLegacyTest = t == 'Labby' && (b == 'تم إنشاء إشعار.' || b == 'Notification created.');
      if (!isLegacyTest) continue;
      batch.delete(d.reference);
      deleted++;
      // Keep batches safely under Firestore limits.
      if (deleted % 400 == 0) {
        await batch.commit();
        batch = _db.batch();
      }
    }
    if (deleted % 400 != 0 && deleted > 0) {
      await batch.commit();
    }
    return deleted;
  }

  Stream<List<AppNotificationModel>> watchForUser(String userId, {int limit = 50}) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotificationModel.fromDoc(d))
            .where((n) => !_isHidden(n))
            .toList());
  }

  /// Total notifications for the user (read + unread), excluding hidden setup banners.
  Stream<int> watchTotalCount(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          var c = 0;
          for (final d in snap.docs) {
            if (!_isHidden(AppNotificationModel.fromDoc(d))) c++;
          }
          return c;
        });
  }

  Stream<int> watchUnreadCount(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.size);
  }

  Future<void> markRead(String id) async {
    await _col.doc(id).set({'isRead': true}, SetOptions(merge: true));
  }

  Future<void> markAllRead(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in snap.docs) {
      batch.set(d.reference, {'isRead': true}, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> addForUser({
    required String userId,
    required String title,
    required String body,
    String type = 'general',
    Map<String, dynamic> data = const {},
    DateTime? createdAt,
  }) async {
    final now = createdAt ?? DateTime.now();
    final doc = AppNotificationModel(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: now,
      isRead: false,
    );
    await _col.add(doc.toMap());

    // Optional: send an email via a free webhook (no Firebase Functions needed).
    // Fire-and-forget to avoid delaying UI.
    unawaited(
      _email.maybeSendNotificationEmail(
        userId: userId,
        title: title,
        body: body,
        data: data,
      ),
    );
  }
}

