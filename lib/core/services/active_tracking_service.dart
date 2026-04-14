import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists "who am I viewing / managing" on the signed-in user's Firestore doc
/// so Profile and Medication stay aligned and survive restarts.
class ActiveTrackingService {
  ActiveTrackingService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String profileUidField = 'activeProfileUid';
  static const String profileLabelField = 'activeProfileLabel';
  static const String medUidField = 'activeMedicationUid';
  static const String medLabelField = 'activeMedicationLabel';

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  /// Null = show signed-in user's profile.
  static String? profileUidFromDoc(Map<String, dynamic>? d, String authUid) {
    final t = (d?[profileUidField] as String?)?.trim();
    if (t == null || t.isEmpty || t == authUid) return null;
    return t;
  }

  /// Firestore `medications.userId` subject (dependents always own uid).
  static String medicationSubjectFromDoc(Map<String, dynamic>? d, String authUid) {
    if (d?['familyRole'] == 'dependent') return authUid;
    final t = (d?[medUidField] as String?)?.trim();
    if (t == null || t.isEmpty || t == authUid) return authUid;
    return t;
  }

  static String medicationLabelFromDoc(Map<String, dynamic>? d, String subjectUid) {
    final label = (d?[medLabelField] as String?)?.trim() ?? '';
    return label.isNotEmpty ? label : subjectUid;
  }

  Future<void> clearAllTracking(String authUid) async {
    await _userRef(authUid).set({
      profileUidField: FieldValue.delete(),
      profileLabelField: FieldValue.delete(),
      medUidField: FieldValue.delete(),
      medLabelField: FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  Future<void> clearDependentProfileView(String authUid) async {
    await _userRef(authUid).set({
      profileUidField: FieldValue.delete(),
      profileLabelField: FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  /// Guardian switches to a linked member (or self): profile + medications follow.
  Future<void> persistGuardianSelection(
    User auth, {
    required String selectedUid,
    required String label,
  }) async {
    if (selectedUid == auth.uid) {
      await clearAllTracking(auth.uid);
      return;
    }
    await _userRef(auth.uid).set({
      profileUidField: selectedUid,
      profileLabelField: label,
      medUidField: selectedUid,
      medLabelField: label,
    }, SetOptions(merge: true));
  }

  /// Dependent views guardian profile only; meds stay on dependent.
  Future<void> persistDependentProfileView(
    User auth, {
    required String guardianUid,
    required String label,
  }) async {
    await _userRef(auth.uid).set({
      profileUidField: guardianUid,
      profileLabelField: label,
      medUidField: FieldValue.delete(),
      medLabelField: FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  /// Medication switcher: guardians sync profile; dependents only clear med fields.
  Future<void> persistMedicationSubject(
    User auth, {
    required String selectedUid,
    required String label,
  }) async {
    final snap = await _userRef(auth.uid).get();
    final role = snap.data()?['familyRole'] as String?;
    if (role == 'dependent') {
      await _userRef(auth.uid).set({
        medUidField: FieldValue.delete(),
        medLabelField: FieldValue.delete(),
      }, SetOptions(merge: true));
      return;
    }
    await persistGuardianSelection(auth, selectedUid: selectedUid, label: label);
  }
}
