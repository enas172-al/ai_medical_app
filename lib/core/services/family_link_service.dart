import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Thrown when family linking fails; [messageKey] is an easy_localization key.
class FamilyLinkException implements Exception {
  final String messageKey;
  FamilyLinkException(this.messageKey);

  @override
  String toString() => messageKey;
}

/// Firebase-backed family invite codes and parent–child linking.
class FamilyLinkService {
  FamilyLinkService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String codesCollection = 'family_codes';
  static const String linksCollection = 'family_links';

  static String normalizeCode(String raw) {
    return raw.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
  }

  String _randomSuffix(int length) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random.secure();
    return List.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }

  /// Ensures a [family_codes] document exists and returns the human-readable code (e.g. LABBY-XXXXXX).
  Future<String> ensureFamilyCodeForGuardian(String guardianUid) async {
    final userRef = _db.collection('users').doc(guardianUid);
    final userSnap = await userRef.get();
    if (!userSnap.exists) {
      throw FamilyLinkException('family_code_user_missing');
    }
    final data = userSnap.data()!;
    if (data['familyRole'] == 'dependent') {
      throw FamilyLinkException('family_code_guardian_only');
    }

    final existing = (data['familyCode'] as String?)?.trim();
    if (existing != null && existing.isNotEmpty) {
      final norm = normalizeCode(existing);
      final codeSnap = await _db.collection(codesCollection).doc(norm).get();
      if (codeSnap.exists &&
          codeSnap.data()?['guardianUid'] == guardianUid) {
        return existing;
      }
    }

    for (var attempt = 0; attempt < 16; attempt++) {
      final code = 'LABBY-${_randomSuffix(6)}';
      final norm = normalizeCode(code);
      try {
        await _db.runTransaction((txn) async {
          final codeRef = _db.collection(codesCollection).doc(norm);
          final c = await txn.get(codeRef);
          if (c.exists) throw StateError('collision');
          txn.set(codeRef, {
            'guardianUid': guardianUid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          txn.set(
            userRef,
            {
              'familyCode': code,
              'familyRole': 'guardian',
            },
            SetOptions(merge: true),
          );
        });
        return code;
      } catch (_) {
        continue;
      }
    }
    throw FamilyLinkException('family_code_generate_failed');
  }

  /// Links [dependentUid] to the guardian that owns [rawCode].
  Future<void> linkDependentAccount({
    required String dependentUid,
    required String? email,
    required String? displayName,
    required String rawCode,
  }) async {
    final code = normalizeCode(rawCode);
    if (code.isEmpty) {
      throw FamilyLinkException('family_code_invalid');
    }

    final codeSnap =
        await _db.collection(codesCollection).doc(code).get();
    if (!codeSnap.exists) {
      throw FamilyLinkException('family_code_not_found');
    }
    final guardianUid = codeSnap.data()?['guardianUid'] as String?;
    if (guardianUid == null || guardianUid.isEmpty) {
      throw FamilyLinkException('family_code_not_found');
    }
    if (guardianUid == dependentUid) {
      throw FamilyLinkException('family_code_self_link');
    }

    final userRef = _db.collection('users').doc(dependentUid);
    final userSnap = await userRef.get();
    final existingGuardian = userSnap.data()?['guardianUid'] as String?;
    if (existingGuardian != null && existingGuardian.isNotEmpty) {
      if (existingGuardian == guardianUid) {
        return;
      }
      throw FamilyLinkException('family_code_already_linked');
    }

    final role = userSnap.data()?['familyRole'] as String?;
    final existingCode =
        (userSnap.data()?['familyCode'] as String?)?.trim() ?? '';
    if (role == 'guardian' && existingCode.isNotEmpty) {
      throw FamilyLinkException('family_code_guardian_cannot_link');
    }

    final batch = _db.batch();
    batch.set(
      userRef,
      {
        'familyRole': 'dependent',
        'guardianUid': guardianUid,
        'linkedFamilyCode': code,
        if (email != null && email.isNotEmpty) 'email': email,
        if (displayName != null && displayName.isNotEmpty) 'name': displayName,
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
      },
      SetOptions(merge: true),
    );

    final linkRef = _db.collection(linksCollection).doc(dependentUid);
    batch.set(linkRef, {
      'guardianUid': guardianUid,
      'dependentUid': dependentUid,
      'dependentEmail': email,
      'dependentName': displayName,
      'linkedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> familyLinksForGuardian(
    String guardianUid,
  ) {
    return _db
        .collection(linksCollection)
        .where('guardianUid', isEqualTo: guardianUid)
        .snapshots();
  }

  /// Dependent profiles linked to this guardian (`users.guardianUid` — same source as linking batch).
  Stream<QuerySnapshot<Map<String, dynamic>>> dependentUserProfilesForGuardian(
    String guardianUid,
  ) {
    return _db
        .collection('users')
        .where('guardianUid', isEqualTo: guardianUid)
        .snapshots();
  }
}
