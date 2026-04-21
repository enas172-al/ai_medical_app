import 'package:cloud_firestore/cloud_firestore.dart';

/// Server-side copy of privacy & security toggles under `users/{uid}.privacySettings.*`.
class PrivacySettingsFirestoreService {
  PrivacySettingsFirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _db.collection('users').doc(uid);

  /// Reads nested privacy map if present.
  Map<String, dynamic>? _privacyMap(Map<String, dynamic>? userData) {
    final m = userData?['privacySettings'];
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  Future<PrivacySettingsRemote?> fetch(String uid) async {
    final snap = await _userRef(uid).get();
    final p = _privacyMap(snap.data());
    if (p == null) return null;
    return PrivacySettingsRemote.fromMap(p);
  }

  Stream<PrivacySettingsRemote?> watch(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      final p = _privacyMap(snap.data());
      if (p == null) return null;
      return PrivacySettingsRemote.fromMap(p);
    });
  }

  /// Uses dotted field paths so Firestore merges nested keys without wiping the whole map.
  Future<void> syncAll(
    String uid, {
    required bool biometricAuth,
    required bool twoFactorAuth,
    required bool autoLock,
    required bool dataEncryption,
    required bool familyShare,
    required bool analyticsData,
  }) async {
    await _userRef(uid).set(
      {
        'privacySettings.biometricAuth': biometricAuth,
        'privacySettings.twoFactorAuth': twoFactorAuth,
        'privacySettings.autoLock': autoLock,
        'privacySettings.dataEncryption': dataEncryption,
        'privacySettings.familyShare': familyShare,
        'privacySettings.analyticsData': analyticsData,
        'privacySettings.updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

class PrivacySettingsRemote {
  final bool biometricAuth;
  final bool twoFactorAuth;
  final bool autoLock;
  final bool dataEncryption;
  final bool familyShare;
  final bool analyticsData;

  const PrivacySettingsRemote({
    required this.biometricAuth,
    required this.twoFactorAuth,
    required this.autoLock,
    required this.dataEncryption,
    required this.familyShare,
    required this.analyticsData,
  });

  static PrivacySettingsRemote fromMap(Map<String, dynamic> m) {
    bool b(dynamic v, bool d) => v is bool ? v : d;
    return PrivacySettingsRemote(
      biometricAuth: b(m['biometricAuth'], false),
      twoFactorAuth: b(m['twoFactorAuth'], false),
      autoLock: b(m['autoLock'], true),
      dataEncryption: b(m['dataEncryption'], true),
      familyShare: b(m['familyShare'], true),
      analyticsData: b(m['analyticsData'], false),
    );
  }
}
