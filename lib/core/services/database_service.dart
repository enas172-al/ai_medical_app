import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/analysis_model.dart';
import '../models/medication_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Analysis Operations ---

  Stream<List<AnalysisModel>> getAnalyses(String userId) {
    return _db
        .collection('analyses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnalysisModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addAnalysis(AnalysisModel analysis) async {
    await _db.collection('analyses').add(analysis.toMap());
  }

  /// Analyses in [start, end] (inclusive), ordered oldest → newest (for charts).
  Future<List<AnalysisModel>> getAnalysesInDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snap = await _db
        .collection('analyses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .get();
    return snap.docs.map((d) => AnalysisModel.fromMap(d.data(), d.id)).toList();
  }

  /// Time series for one test (e.g. Glucose), ascending by date.
  Future<List<AnalysisModel>> getAnalysesByTestName(
    String userId,
    String testName, {
    DateTime? start,
    DateTime? end,
  }) async {
    final s = start ?? DateTime.now().subtract(const Duration(days: 365));
    final e = end ?? DateTime.now();
    final snap = await _db
        .collection('analyses')
        .where('userId', isEqualTo: userId)
        .where('testName', isEqualTo: testName)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(s))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(e))
        .orderBy('date')
        .get();
    return snap.docs.map((d) => AnalysisModel.fromMap(d.data(), d.id)).toList();
  }

  // --- Medication Operations ---

  /// Single-field filter only (no server `orderBy`) so a composite index is not required;
  /// sort by [createdAt] in memory.
  Stream<List<MedicationModel>> getMedications(String userId) {
    return _db
        .collection('medications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Create or replace document. Returns document id.
  Future<String> saveMedication(MedicationModel medication) async {
    final data = medication.toMap();
    if (medication.id != null && medication.id!.isNotEmpty) {
      await _db.collection('medications').doc(medication.id).set(data, SetOptions(merge: true));
      return medication.id!;
    }
    final ref = await _db.collection('medications').add(data);
    return ref.id;
  }

  Future<void> addMedication(MedicationModel medication) async {
    await saveMedication(medication);
  }

  Future<void> updateMedicationStatus(String docId, bool isActive) async {
    await _db.collection('medications').doc(docId).update({'isActive': isActive});
  }

  Future<void> deleteMedication(String docId) async {
    await _db.collection('medications').doc(docId).delete();
  }
}
