import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationReminderFirestoreService {
  MedicationReminderFirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('medication_reminders');

  static String _docId(String userId, String medId, String time) {
    // Deterministic id so edits overwrite instead of creating duplicates.
    return '${userId}_${medId}_${time.hashCode.abs()}';
  }

  Future<void> upsertReminder({
    required String userId,
    required String medId,
    required String medicationName,
    required String time,
    required List<int> daysOfWeek,
  }) async {
    final id = _docId(userId, medId, time);
    await _col.doc(id).set(
      {
        'userId': userId,
        'medId': medId,
        'medicationName': medicationName,
        'time': time,
        'daysOfWeek': daysOfWeek,
        'updatedAt': FieldValue.serverTimestamp(),
        // set only once
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

