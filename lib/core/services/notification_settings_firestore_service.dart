import 'package:cloud_firestore/cloud_firestore.dart';

/// Server-side copy of notification toggles under `users/{uid}.notificationSettings.*`.
class NotificationSettingsFirestoreService {
  NotificationSettingsFirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _db.collection('users').doc(uid);

  Map<String, dynamic>? _map(Map<String, dynamic>? userData) {
    final m = userData?['notificationSettings'];
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  Future<NotificationSettingsRemote?> fetch(String uid) async {
    final snap = await _userRef(uid).get();
    final m = _map(snap.data());
    if (m == null) return null;
    return NotificationSettingsRemote.fromMap(m);
  }

  Stream<NotificationSettingsRemote?> watch(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      final m = _map(snap.data());
      if (m == null) return null;
      return NotificationSettingsRemote.fromMap(m);
    });
  }

  Future<void> syncAll(
    String uid, {
    required bool pushEnabled,
    required bool emailEnabled,
  }) async {
    await _userRef(uid).set(
      {
        'notificationSettings.pushEnabled': pushEnabled,
        'notificationSettings.emailEnabled': emailEnabled,
        'notificationSettings.updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

class NotificationSettingsRemote {
  final bool pushEnabled;
  final bool emailEnabled;

  const NotificationSettingsRemote({
    required this.pushEnabled,
    required this.emailEnabled,
  });

  static NotificationSettingsRemote fromMap(Map<String, dynamic> m) {
    bool b(dynamic v, bool d) => v is bool ? v : d;
    return NotificationSettingsRemote(
      pushEnabled: b(m['pushEnabled'], true),
      emailEnabled: b(m['emailEnabled'], true),
    );
  }
}

