import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // e.g. 'medication', 'analysis', 'general'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotificationModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? const <String, dynamic>{};
    final ts = m['createdAt'];
    final created = ts is Timestamp ? ts.toDate() : DateTime.now();
    return AppNotificationModel(
      id: doc.id,
      userId: (m['userId'] as String?) ?? '',
      title: (m['title'] as String?) ?? '',
      body: (m['body'] as String?) ?? '',
      type: (m['type'] as String?) ?? 'general',
      data: Map<String, dynamic>.from((m['data'] as Map?) ?? const {}),
      createdAt: created,
      isRead: (m['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}

