import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification_model.dart';

class NotificationsRepository {
  NotificationsRepository({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('notifications');

  Stream<List<AppNotificationModel>> watchForUser(String userId, {int limit = 50}) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppNotificationModel.fromDoc(d)).toList());
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
  }
}

