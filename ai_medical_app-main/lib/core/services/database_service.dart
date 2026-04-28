import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import '../models/analysis_model.dart';
import '../models/medication_model.dart';
import '../models/test_definition_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> get _metaDoc =>
      _db.collection('meta').doc('test_definitions_seed');

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

  /// One-shot fetch (no server orderBy) — sort by [date] descending in memory.
  Future<List<AnalysisModel>> getAnalysesOnce(String userId) async {
    final snap = await _db.collection('analyses').where('userId', isEqualTo: userId).get();
    final list =
        snap.docs.map((d) => AnalysisModel.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
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
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MedicationModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// One-shot fetch; optionally include inactive meds (archived).
  Future<List<MedicationModel>> getMedicationsOnce(
    String userId, {
    bool includeInactive = false,
  }) async {
    Query<Map<String, dynamic>> q =
        _db.collection('medications').where('userId', isEqualTo: userId);
    if (!includeInactive) {
      q = q.where('isActive', isEqualTo: true);
    }
    final snap = await q.get();
    final list =
        snap.docs.map((d) => MedicationModel.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
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

  static String normalizeMedicationKey(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return '';
    final lower = trimmed.toLowerCase();
    final noDiacritics = lower
        // Arabic tashkeel + superscript alef + tatweel
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('\u0640', '');
    final arabicNormalized = noDiacritics
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه');
    // collapse whitespace
    final collapsed = arabicNormalized.replaceAll(RegExp(r'\s+'), ' ');
    // normalize common dose formats: "1 mg" -> "1mg"
    final doseTight = collapsed.replaceAllMapped(
      RegExp(r'(\d)\s+(mg|g|mcg|ug|iu|ml|mmol/l|mmol|%)\b', caseSensitive: false),
      (m) => '${m[1]}${m[2]}',
    );
    return doseTight;
  }

  // --- Test Definitions (Search) ---

  /// NOTE: if you change this name, also change the Firebase Console view accordingly.
  static const String testDefinitionsCollection = 'lab_tests';
  static const String _legacyTestDefinitionsCollection = 'test_definitions';

  CollectionReference<Map<String, dynamic>> get _testsCol =>
      _db.collection(testDefinitionsCollection);

  CollectionReference<Map<String, dynamic>> get _testsColLegacy =>
      _db.collection(_legacyTestDefinitionsCollection);

  Future<QuerySnapshot<Map<String, dynamic>>> _safeGet(
    Query<Map<String, dynamic>> q,
  ) async {
    try {
      return await q.get();
    } on FirebaseException catch (_) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getFromActiveOrLegacy(
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>> col) build,
  ) async {
    // 1) try active collection
    try {
      final snap = await _safeGet(build(_testsCol));
      if (snap.docs.isNotEmpty) return snap;
    } catch (_) {
      // ignore and fallback
    }
    // 2) fallback to legacy
    return await _safeGet(build(_testsColLegacy));
  }

  static String _normalizeQuery(String q) {
    final trimmed = q.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    // collapse whitespace
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _normalizeArabic(String s) {
    // Remove tashkeel + tatweel and normalize common Arabic letter variants.
    final noDiacritics = s
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('\u0640', '');
    return noDiacritics
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ة', 'ه');
  }

  Future<Map<String, List<TestDefinitionModel>>> listTestDefinitionsGrouped({
    int limit = 50,
  }) async {
    final snap = await _getFromActiveOrLegacy((col) => col.limit(limit));
    final items = snap.docs.map((d) => TestDefinitionModel.fromDoc(d)).toList();
    final Map<String, List<TestDefinitionModel>> grouped = {};
    for (final item in items) {
      final key = item.category.isNotEmpty ? item.category : 'أخرى';
      (grouped[key] ??= []).add(item);
    }
    return grouped;
  }

  /// Ensures Mayo Labs tests are imported once (idempotent).
  /// Writes up to [limit] docs into `test_definitions` and stores a flag in `meta/test_definitions_seed`.
  Future<int> ensureMayoLabsSeededOnce({int limit = 500}) async {
    // If the user deleted `test_definitions` manually, the meta flag might still be set.
    // In that case, re-seed when the collection is empty.
    final hasAny = await _testsCol.limit(1).get().then((s) => s.docs.isNotEmpty);

    final snap = await _metaDoc.get();
    final done = (snap.data()?['mayoLabsImported'] == true);
    if (done && hasAny) return 0;

    final count = await importMayoLabsTests(limit: limit);
    await _metaDoc.set({
      'mayoLabsImported': true,
      'importedCount': count,
      'importedAt': FieldValue.serverTimestamp(),
      'sourceHost': _mayoLabsHost,
      'reseededBecauseEmpty': done && !hasAny,
    }, SetOptions(merge: true));
    return count;
  }

  /// Ensures the lab tests from the bundled PDF list are imported once (idempotent).
  /// Writes docs into `test_definitions` and stores a flag in `meta/test_definitions_seed`.
  Future<int> ensurePdfLabTestsSeededOnce() async {
    final hasAnyActive = await _testsCol.limit(1).get().then((s) => s.docs.isNotEmpty);
    final hasAnyLegacy = await _testsColLegacy.limit(1).get().then((s) => s.docs.isNotEmpty);
    final hasAny = hasAnyActive || hasAnyLegacy;
    final snap = await _metaDoc.get();
    final done = (snap.data()?['pdfLabTestsImported'] == true);
    if (done && hasAny) return 0;

    int count = 0;
    try {
      count = await seedPdfLabTests();
    } on FirebaseException catch (e) {
      // If active collection is blocked by rules, fallback to legacy collection
      // (keeps the app working even before rules deploy).
      final code = e.code.toLowerCase();
      if (code.contains('permission') || code.contains('denied')) {
        count = await seedPdfLabTests(collectionNameOverride: _legacyTestDefinitionsCollection);
      } else {
        rethrow;
      }
    }
    await _metaDoc.set({
      'pdfLabTestsImported': true,
      'pdfImportedCount': count,
      'pdfImportedAt': FieldValue.serverTimestamp(),
      'pdfName': '300_lab_tests.pdf',
      'reseededBecauseEmpty': done && !hasAny,
    }, SetOptions(merge: true));
    return count;
  }

  /// Search test definitions and return grouped results by [category].
  ///
  /// Data model (Firestore collection: `test_definitions`)
  /// - nameAr/nameEn/shortCode
  /// - nameArLower/nameEnLower (pre-lowercased)
  /// - keywords: array of lowercase tokens & aliases
  /// - category/unit/normalMin/normalMax/highText/lowText
  Future<Map<String, List<TestDefinitionModel>>> searchTestDefinitionsGrouped(
    String query, {
    int limitPerQuery = 20,
  }) async {
    final q = _normalizeQuery(query);
    if (q.isEmpty) return <String, List<TestDefinitionModel>>{};

    final qArNorm = _normalizeArabic(q);
    final tokens = q.split(' ').where((t) => t.isNotEmpty).toList();
    final normTokens = qArNorm.split(' ').where((t) => t.isNotEmpty).toList();

    // Try a few keyword tokens (exact match per element) and merge results.
    final keywordSnaps = <QuerySnapshot<Map<String, dynamic>>>[];
    final tokenCandidates = <String>{
      if (tokens.isNotEmpty) tokens.first,
      if (tokens.length >= 2) tokens[1],
      if (normTokens.isNotEmpty) normTokens.first,
      if (normTokens.length >= 2) normTokens[1],
    }.where((t) => t.trim().isNotEmpty).toList();
    for (final t in tokenCandidates.take(3)) {
      keywordSnaps.add(
        await _getFromActiveOrLegacy(
          (col) => col.where('keywords', arrayContains: t).limit(limitPerQuery),
        ),
      );
    }

    // Prefix search on Arabic name
    final byArPrefix = await _getFromActiveOrLegacy(
      (col) => col
          .orderBy('nameArLower')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(limitPerQuery),
    );

    // Prefix search on Arabic normalized name (if field exists)
    QuerySnapshot<Map<String, dynamic>>? byArNormPrefix;
    try {
      byArNormPrefix = await _getFromActiveOrLegacy(
        (col) => col
            .orderBy('nameArNorm')
            .startAt([qArNorm])
            .endAt(['$qArNorm\uf8ff'])
            .limit(limitPerQuery),
      );
    } catch (_) {
      // If the field/index doesn't exist yet, ignore.
      byArNormPrefix = null;
    }

    // Prefix search on English name
    final byEnPrefix = await _getFromActiveOrLegacy(
      (col) => col
          .orderBy('nameEnLower')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(limitPerQuery),
    );

    // Merge unique by id
    final Map<String, TestDefinitionModel> merged = {};
    final allSnaps = <QuerySnapshot<Map<String, dynamic>>>[
      ...keywordSnaps,
      byArPrefix,
      byEnPrefix,
      if (byArNormPrefix != null) byArNormPrefix,
    ];
    for (final snap in allSnaps) {
      for (final doc in snap.docs) {
        merged[doc.id] = TestDefinitionModel.fromDoc(doc);
      }
    }

    final list = merged.values.toList()
      ..sort((a, b) {
        // Prefer closer matches: exact token/startsWith
        final aScore = _matchScore(a, q);
        final bScore = _matchScore(b, q);
        final byScore = bScore.compareTo(aScore);
        if (byScore != 0) return byScore;
        return a.nameAr.compareTo(b.nameAr);
      });

    final Map<String, List<TestDefinitionModel>> grouped = {};
    for (final item in list) {
      final key = item.category.isNotEmpty ? item.category : 'أخرى';
      (grouped[key] ??= []).add(item);
    }
    return grouped;
  }

  static int _matchScore(TestDefinitionModel t, String q) {
    final ar = t.nameArLower;
    final arNorm = t.nameArNorm ?? '';
    final en = t.nameEnLower;
    if (ar == q || en == q) return 100;
    if (ar.startsWith(q) || en.startsWith(q)) return 80;
    if (t.keywords.contains(q)) return 70;
    if (ar.contains(q) || en.contains(q) || arNorm.contains(_normalizeArabic(q))) return 50;
    return 0;
  }

  /// Optional helper to seed a few common tests (safe to call multiple times).
  /// Writes to `test_definitions` using deterministic document ids.
  Future<void> seedDefaultTestDefinitions() async {
    final now = DateTime.now();
    final items = <TestDefinitionModel>[
      _seed(
        id: 'glucose_fasting',
        nameAr: 'سكر صائم',
        nameEn: 'Fasting Glucose',
        shortCode: 'Glucose',
        category: 'السكر',
        unit: 'mg/dL',
        normalMin: 70,
        normalMax: 100,
        highText: 'قد يشير ارتفاع سكر الدم إلى مقاومة الإنسولين أو السكري، ويحتاج لتقييم طبي.',
        lowText: 'قد يشير انخفاض سكر الدم إلى هبوط سكر، وقد يسبب دوخة/تعرق ويحتاج متابعة.',
        now: now,
        aliases: ['glucose', 'سكر', 'سكر صايم', 'fasting sugar', 'fbs'],
      ),
      _seed(
        id: 'hemoglobin',
        nameAr: 'الهيموجلوبين',
        nameEn: 'Hemoglobin',
        shortCode: 'Hb',
        category: 'الدم',
        unit: 'g/dL',
        normalMin: 13,
        normalMax: 17,
        highText: 'قد يرتفع بسبب الجفاف أو أمراض معينة ويحتاج لتقييم حسب الحالة.',
        lowText: 'قد يشير لانيميا/نقص حديد أو نزف ويحتاج تقييم طبي.',
        now: now,
        aliases: ['hb', 'hgb', 'hemoglobin', 'هيموجلوبين'],
      ),
      _seed(
        id: 'cholesterol_total',
        nameAr: 'الكوليسترول الكلي',
        nameEn: 'Total Cholesterol',
        shortCode: 'Chol',
        category: 'الدهون',
        unit: 'mg/dL',
        normalMin: null,
        normalMax: 200,
        highText: 'قد يزيد خطر أمراض القلب ويحتاج لتعديل نمط حياة/علاج حسب الطبيب.',
        lowText: 'الانخفاض غالبًا أقل شيوعًا وقد يرتبط بحالات غذائية/هرمونية.',
        now: now,
        aliases: ['cholesterol', 'chol', 'lipid', 'كوليسترول'],
      ),
      _seed(
        id: 'vitamin_d',
        nameAr: 'فيتامين د',
        nameEn: 'Vitamin D',
        shortCode: 'Vit D',
        category: 'الفيتامينات',
        unit: 'ng/mL',
        normalMin: 20,
        normalMax: 50,
        highText: 'الارتفاع قد يحدث مع المكملات الزائدة وقد يسبب أعراض ويحتاج متابعة.',
        lowText: 'النقص شائع وقد يؤثر على العظام/المناعة ويحتاج تقييم وتعويض.',
        now: now,
        aliases: ['vitamin d', 'vit d', '25(oh)d', 'vit d3', 'فيتامين د'],
      ),
      _seed(
        id: 'creatinine',
        nameAr: 'الكرياتينين',
        nameEn: 'Creatinine',
        shortCode: 'Cr',
        category: 'الكلى',
        unit: 'mg/dL',
        normalMin: 0.6,
        normalMax: 1.3,
        highText: 'قد يشير لمشكلة في وظائف الكلى أو الجفاف ويحتاج لتقييم طبي.',
        lowText: 'قد ينخفض مع نقص الكتلة العضلية أو حالات أخرى.',
        now: now,
        aliases: ['creatinine', 'cr', 'كرياتينين'],
      ),
      _seed(
        id: 'alt',
        nameAr: 'إنزيم الكبد ALT',
        nameEn: 'ALT (SGPT)',
        shortCode: 'ALT',
        category: 'الكبد',
        unit: 'U/L',
        normalMin: 7,
        normalMax: 56,
        highText: 'قد يشير لالتهاب/إجهاد بالكبد أو أدوية؛ يحتاج تفسير مع باقي التحاليل.',
        lowText: 'الانخفاض عادة غير مقلق ويُفسر حسب السياق.',
        now: now,
        aliases: ['alt', 'sgpt', 'enzyme alt', 'انزيم alt'],
      ),
      _seed(
        id: 'wbc',
        nameAr: 'كرات الدم البيضاء',
        nameEn: 'White Blood Cells',
        shortCode: 'WBC',
        category: 'الدم',
        unit: '/µL',
        normalMin: 4000,
        normalMax: 11000,
        highText: 'قد يدل على عدوى/التهاب أو أسباب أخرى ويحتاج تقييم طبي.',
        lowText: 'قد يدل على نقص مناعة/أدوية؛ يحتاج متابعة حسب الطبيب.',
        now: now,
        aliases: ['wbc', 'white blood cells', 'كرات دم بيضاء', 'كريات بيضاء'],
      ),
      _seed(
        id: 'platelets',
        nameAr: 'الصفائح الدموية',
        nameEn: 'Platelets',
        shortCode: 'PLT',
        category: 'الدم',
        unit: '/µL',
        normalMin: 150000,
        normalMax: 450000,
        highText: 'قد يزيد خطر الجلطات في بعض الحالات ويحتاج تقييم طبي.',
        lowText: 'قد يزيد خطر النزف ويحتاج تقييم عاجل حسب الأعراض.',
        now: now,
        aliases: ['platelets', 'plt', 'صفائح', 'platelet count'],
      ),
      _seed(
        id: 'rbc',
        nameAr: 'كرات الدم الحمراء',
        nameEn: 'Red Blood Cells',
        shortCode: 'RBC',
        category: 'الدم',
        unit: 'million/µL',
        normalMin: 4.2,
        normalMax: 5.9,
        highText: 'قد ترتفع مع الجفاف أو التدخين أو حالات أخرى؛ يحتاج تقييم حسب الحالة.',
        lowText: 'قد تنخفض مع الأنيميا أو النزف أو نقص الحديد؛ يحتاج تقييم طبي.',
        now: now,
        aliases: ['rbc', 'red blood cells', 'كرات دم حمراء', 'كريات حمراء'],
      ),
      _seed(
        id: 'hct',
        nameAr: 'الهيماتوكريت',
        nameEn: 'Hematocrit',
        shortCode: 'HCT',
        category: 'الدم',
        unit: '%',
        normalMin: 38,
        normalMax: 52,
        highText: 'قد يرتفع مع الجفاف أو كثرة الحمر؛ يحتاج تفسير مع CBC.',
        lowText: 'قد ينخفض مع الأنيميا أو النزف؛ يحتاج تقييم.',
        now: now,
        aliases: ['hct', 'hematocrit', 'هيماتوكريت'],
      ),
      _seed(
        id: 'mcv',
        nameAr: 'متوسط حجم الكريات',
        nameEn: 'Mean Corpuscular Volume',
        shortCode: 'MCV',
        category: 'الدم',
        unit: 'fL',
        normalMin: 80,
        normalMax: 100,
        highText: 'قد يشير لنقص فيتامين B12/فولات أو أسباب أخرى.',
        lowText: 'قد يشير لنقص الحديد أو ثلاسيميا؛ يحتاج تقييم.',
        now: now,
        aliases: ['mcv', 'mean corpuscular volume', 'حجم الكريات', 'متوسط حجم الكريات'],
      ),
      _seed(
        id: 'ast',
        nameAr: 'إنزيم الكبد AST',
        nameEn: 'AST (SGOT)',
        shortCode: 'AST',
        category: 'الكبد',
        unit: 'U/L',
        normalMin: 10,
        normalMax: 40,
        highText: 'قد يرتفع مع التهاب كبد أو إجهاد عضلي أو أدوية؛ يحتاج تفسير مع ALT.',
        lowText: 'الانخفاض عادة غير مهم سريريًا.',
        now: now,
        aliases: ['ast', 'sgot', 'enzyme ast', 'انزيم ast'],
      ),
      _seed(
        id: 'alp',
        nameAr: 'الفوسفاتاز القلوي',
        nameEn: 'Alkaline Phosphatase',
        shortCode: 'ALP',
        category: 'الكبد',
        unit: 'U/L',
        normalMin: 44,
        normalMax: 147,
        highText: 'قد يرتفع مع مشاكل بالقنوات المرارية أو العظام؛ يحتاج تقييم.',
        lowText: 'قد ينخفض مع سوء تغذية/نقص زنك أو حالات أخرى.',
        now: now,
        aliases: ['alp', 'alkaline phosphatase', 'فوسفاتاز', 'الفوسفاتاز القلوي'],
      ),
      _seed(
        id: 'bilirubin_total',
        nameAr: 'البيليروبين الكلي',
        nameEn: 'Total Bilirubin',
        shortCode: 'Bili',
        category: 'الكبد',
        unit: 'mg/dL',
        normalMin: 0.1,
        normalMax: 1.2,
        highText: 'قد يسبب اصفرار ويشير لمشاكل كبد/مرارة أو تكسير دم؛ يحتاج تقييم.',
        lowText: 'الانخفاض عادة غير مهم.',
        now: now,
        aliases: ['bilirubin', 'total bilirubin', 'bili', 'بيليروبين'],
      ),
      _seed(
        id: 'bun',
        nameAr: 'يوريا الدم',
        nameEn: 'Blood Urea Nitrogen',
        shortCode: 'BUN',
        category: 'الكلى',
        unit: 'mg/dL',
        normalMin: 7,
        normalMax: 20,
        highText: 'قد يرتفع مع الجفاف أو مشاكل كلى أو نظام غذائي عالي البروتين.',
        lowText: 'قد ينخفض مع سوء تغذية أو مشاكل كبد؛ يفسر حسب الحالة.',
        now: now,
        aliases: ['bun', 'urea', 'blood urea nitrogen', 'يوريا'],
      ),
      _seed(
        id: 'egfr',
        nameAr: 'معدل الترشيح الكبيبي',
        nameEn: 'Estimated GFR',
        shortCode: 'eGFR',
        category: 'الكلى',
        unit: 'mL/min/1.73m²',
        normalMin: 90,
        normalMax: null,
        highText: 'لا يُستخدم عادة كـ “مرتفع”؛ الأهم هو الانخفاض.',
        lowText: 'انخفاض eGFR قد يشير لتراجع وظائف الكلى ويحتاج متابعة.',
        now: now,
        aliases: ['egfr', 'gfr', 'estimated gfr', 'ترشيح', 'معدل الترشيح'],
      ),
      _seed(
        id: 'sodium',
        nameAr: 'الصوديوم',
        nameEn: 'Sodium',
        shortCode: 'Na',
        category: 'الأملاح',
        unit: 'mmol/L',
        normalMin: 135,
        normalMax: 145,
        highText: 'قد يسبب عطش/ارتباك؛ يحتاج تقييم السبب (جفاف/أدوية...).',
        lowText: 'قد يسبب صداع/دوخة وقد يكون خطير؛ يحتاج تقييم طبي.',
        now: now,
        aliases: ['sodium', 'na', 'صوديوم'],
      ),
      _seed(
        id: 'potassium',
        nameAr: 'البوتاسيوم',
        nameEn: 'Potassium',
        shortCode: 'K',
        category: 'الأملاح',
        unit: 'mmol/L',
        normalMin: 3.5,
        normalMax: 5.1,
        highText: 'قد يؤثر على ضربات القلب؛ يحتاج تقييم سريع حسب المستوى.',
        lowText: 'قد يسبب ضعف/تقلصات وقد يؤثر على القلب؛ يحتاج علاج حسب السبب.',
        now: now,
        aliases: ['potassium', 'k', 'بوتاسيوم'],
      ),
      _seed(
        id: 'calcium',
        nameAr: 'الكالسيوم',
        nameEn: 'Calcium',
        shortCode: 'Ca',
        category: 'الأملاح',
        unit: 'mg/dL',
        normalMin: 8.5,
        normalMax: 10.5,
        highText: 'قد يسبب عطش/إمساك أو حصوات؛ يحتاج تقييم السبب.',
        lowText: 'قد يسبب تنميل/تقلصات؛ يحتاج تقييم (Vit D/غدة جاردرقية...).',
        now: now,
        aliases: ['calcium', 'ca', 'كالسيوم'],
      ),
      _seed(
        id: 'tsh',
        nameAr: 'الهرمون المحفز للغدة الدرقية',
        nameEn: 'Thyroid Stimulating Hormone',
        shortCode: 'TSH',
        category: 'الغدة الدرقية',
        unit: 'mIU/L',
        normalMin: 0.4,
        normalMax: 4.0,
        highText: 'قد يشير لقصور الغدة الدرقية؛ يحتاج تفسير مع FT4.',
        lowText: 'قد يشير لفرط نشاط الغدة أو جرعة زائدة من العلاج؛ يحتاج تقييم.',
        now: now,
        aliases: ['tsh', 'thyroid stimulating hormone', 'غدة', 'درقية', 'TSH'],
      ),
      _seed(
        id: 'ft4',
        nameAr: 'الثيروكسين الحر',
        nameEn: 'Free T4',
        shortCode: 'FT4',
        category: 'الغدة الدرقية',
        unit: 'ng/dL',
        normalMin: 0.8,
        normalMax: 1.8,
        highText: 'قد يشير لفرط نشاط الغدة (مع TSH منخفض).',
        lowText: 'قد يشير لقصور الغدة (مع TSH مرتفع).',
        now: now,
        aliases: ['ft4', 'free t4', 'thyroxine', 'ثيروكسين', 't4'],
      ),
      _seed(
        id: 'ldl',
        nameAr: 'كوليسترول LDL',
        nameEn: 'LDL Cholesterol',
        shortCode: 'LDL',
        category: 'الدهون',
        unit: 'mg/dL',
        normalMin: null,
        normalMax: 100,
        highText: 'ارتفاع LDL يزيد خطر أمراض القلب؛ يحتاج خطة علاج/نمط حياة.',
        lowText: 'الانخفاض عادة جيد؛ يفسر حسب الحالة.',
        now: now,
        aliases: ['ldl', 'ldl cholesterol', 'كوليسترول ضار', 'LDL'],
      ),
      _seed(
        id: 'hdl',
        nameAr: 'كوليسترول HDL',
        nameEn: 'HDL Cholesterol',
        shortCode: 'HDL',
        category: 'الدهون',
        unit: 'mg/dL',
        normalMin: 40,
        normalMax: null,
        highText: 'ارتفاع HDL غالبًا مفيد.',
        lowText: 'انخفاض HDL قد يزيد خطر القلب؛ يفيد تحسين النشاط/النظام الغذائي.',
        now: now,
        aliases: ['hdl', 'hdl cholesterol', 'كوليسترول نافع', 'HDL'],
      ),
      _seed(
        id: 'triglycerides',
        nameAr: 'الدهون الثلاثية',
        nameEn: 'Triglycerides',
        shortCode: 'TG',
        category: 'الدهون',
        unit: 'mg/dL',
        normalMin: null,
        normalMax: 150,
        highText: 'قد يرتبط بالسكر/السمنة ويزيد خطر التهاب البنكرياس عند الارتفاع الشديد.',
        lowText: 'الانخفاض غالبًا غير مقلق.',
        now: now,
        aliases: ['triglycerides', 'tg', 'دهون ثلاثية', 'trigs'],
      ),
    ];

    final batch = _db.batch();
    for (final item in items) {
      batch.set(_testsCol.doc(item.id), item.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  /// Seed a curated set of lab tests extracted from `300_lab_tests.pdf`.
  /// Uses deterministic document ids and is safe to call multiple times.
  Future<int> seedPdfLabTests({String? collectionNameOverride}) async {
    final now = DateTime.now();
    final items = <TestDefinitionModel>[
      // Hematology
      _seedPdf(
        id: 'pdf_hemoglobin',
        nameAr: 'الهيموجلوبين',
        nameEn: 'Hemoglobin',
        shortCode: 'Hb',
        category: 'الدم',
        unit: 'g/dL',
        normalMin: 12.1,
        normalMax: 17.2,
        referenceText: 'Men: 13.8–17.2 g/dL, Women: 12.1–15.1 g/dL',
        now: now,
        aliases: ['hb', 'hgb', 'hemoglobin', 'هيموجلوبين', 'هيموغلوبين'],
      ),
      _seedPdf(
        id: 'pdf_hematocrit',
        nameAr: 'الهيماتوكريت',
        nameEn: 'Hematocrit',
        shortCode: 'HCT',
        category: 'الدم',
        unit: '%',
        normalMin: 36,
        normalMax: 52,
        referenceText: 'Men: 40–52%, Women: 36–48%',
        now: now,
        aliases: ['hct', 'hematocrit', 'هيماتوكريت'],
      ),
      _seedPdf(
        id: 'pdf_wbc',
        nameAr: 'كرات الدم البيضاء',
        nameEn: 'WBC',
        shortCode: 'WBC',
        category: 'الدم',
        unit: '/µL',
        normalMin: 4000,
        normalMax: 11000,
        referenceText: '4,000–11,000 /µL',
        now: now,
        aliases: ['wbc', 'white blood cells', 'كريات بيضاء', 'كرات دم بيضاء'],
      ),
      _seedPdf(
        id: 'pdf_platelets',
        nameAr: 'الصفائح الدموية',
        nameEn: 'Platelets',
        shortCode: 'PLT',
        category: 'الدم',
        unit: '/µL',
        normalMin: 150000,
        normalMax: 450000,
        referenceText: '150,000–450,000 /µL',
        now: now,
        aliases: ['platelets', 'plt', 'صفائح', 'platelet count'],
      ),
      _seedPdf(
        id: 'pdf_rbc',
        nameAr: 'كرات الدم الحمراء',
        nameEn: 'RBC',
        shortCode: 'RBC',
        category: 'الدم',
        unit: 'million/µL',
        normalMin: 4.2,
        normalMax: 6.1,
        referenceText: '4.7–6.1 (men), 4.2–5.4 (women) million/µL',
        now: now,
        aliases: ['rbc', 'red blood cells', 'كريات حمراء', 'كرات دم حمراء'],
      ),

      // Biochemistry
      _seedPdf(
        id: 'pdf_glucose_fasting',
        nameAr: 'سكر الدم',
        nameEn: 'Glucose',
        shortCode: 'Glucose',
        category: 'السكريات',
        unit: 'mg/dL',
        normalMin: 70,
        normalMax: 100,
        referenceText: 'Fasting: 70–100 mg/dL',
        now: now,
        aliases: ['glucose', 'fasting glucose', 'fbs', 'سكر', 'سكر صائم'],
      ),
      _seedPdf(
        id: 'pdf_creatinine',
        nameAr: 'الكرياتينين',
        nameEn: 'Creatinine',
        shortCode: 'Cr',
        category: 'الكلى',
        unit: 'mg/dL',
        normalMin: 0.6,
        normalMax: 1.3,
        referenceText: '0.6–1.3 mg/dL',
        now: now,
        aliases: ['creatinine', 'cr', 'كرياتينين'],
      ),
      _seedPdf(
        id: 'pdf_urea',
        nameAr: 'اليوريا',
        nameEn: 'Urea',
        shortCode: 'Urea',
        category: 'الكلى',
        unit: 'mg/dL',
        normalMin: 7,
        normalMax: 20,
        referenceText: '7–20 mg/dL',
        now: now,
        aliases: ['urea', 'bun', 'يوريا', 'بولة'],
      ),
      _seedPdf(
        id: 'pdf_calcium',
        nameAr: 'الكالسيوم',
        nameEn: 'Calcium',
        shortCode: 'Ca',
        category: 'الأملاح',
        unit: 'mg/dL',
        normalMin: 8.6,
        normalMax: 10.2,
        referenceText: '8.6–10.2 mg/dL',
        now: now,
        aliases: ['calcium', 'ca', 'كالسيوم'],
      ),
      _seedPdf(
        id: 'pdf_sodium',
        nameAr: 'الصوديوم',
        nameEn: 'Sodium',
        shortCode: 'Na',
        category: 'الأملاح',
        unit: 'mEq/L',
        normalMin: 135,
        normalMax: 145,
        referenceText: '135–145 mEq/L',
        now: now,
        aliases: ['sodium', 'na', 'صوديوم'],
      ),
      _seedPdf(
        id: 'pdf_potassium',
        nameAr: 'البوتاسيوم',
        nameEn: 'Potassium',
        shortCode: 'K',
        category: 'الأملاح',
        unit: 'mEq/L',
        normalMin: 3.5,
        normalMax: 5.0,
        referenceText: '3.5–5.0 mEq/L',
        now: now,
        aliases: ['potassium', 'k', 'بوتاسيوم'],
      ),

      // Liver Function
      _seedPdf(
        id: 'pdf_alt',
        nameAr: 'إنزيمات الكبد ALT',
        nameEn: 'ALT',
        shortCode: 'ALT',
        category: 'الكبد',
        unit: 'U/L',
        normalMin: 7,
        normalMax: 56,
        referenceText: '7–56 U/L',
        now: now,
        aliases: ['alt', 'sgpt', 'انزيم alt', 'إنزيم ALT'],
      ),
      _seedPdf(
        id: 'pdf_ast',
        nameAr: 'إنزيمات الكبد AST',
        nameEn: 'AST',
        shortCode: 'AST',
        category: 'الكبد',
        unit: 'U/L',
        normalMin: 10,
        normalMax: 40,
        referenceText: '10–40 U/L',
        now: now,
        aliases: ['ast', 'sgot', 'انزيم ast', 'إنزيم AST'],
      ),
      _seedPdf(
        id: 'pdf_alp',
        nameAr: 'الفوسفاتاز القلوي',
        nameEn: 'ALP',
        shortCode: 'ALP',
        category: 'الكبد',
        unit: 'IU/L',
        normalMin: 44,
        normalMax: 147,
        referenceText: '44–147 IU/L',
        now: now,
        aliases: ['alp', 'alkaline phosphatase', 'فوسفاتاز', 'الفوسفاتاز القلوي'],
      ),
      _seedPdf(
        id: 'pdf_bilirubin_total',
        nameAr: 'البيليروبين الكلي',
        nameEn: 'Total Bilirubin',
        shortCode: 'Bili',
        category: 'الكبد',
        unit: 'mg/dL',
        normalMin: 0.1,
        normalMax: 1.2,
        referenceText: '0.1–1.2 mg/dL',
        now: now,
        aliases: ['bilirubin', 'total bilirubin', 'bili', 'بيليروبين'],
      ),

      // Hormones
      _seedPdf(
        id: 'pdf_tsh',
        nameAr: 'هرمون الغدة الدرقية TSH',
        nameEn: 'TSH',
        shortCode: 'TSH',
        category: 'الهرمونات',
        unit: 'mIU/L',
        normalMin: 0.4,
        normalMax: 4.0,
        referenceText: '0.4–4.0 mIU/L',
        now: now,
        aliases: ['tsh', 'thyroid stimulating hormone', 'الغدة الدرقية', 'درقية'],
      ),
      _seedPdf(
        id: 'pdf_free_t4',
        nameAr: 'الثيروكسين الحر',
        nameEn: 'Free T4',
        shortCode: 'FT4',
        category: 'الهرمونات',
        unit: 'ng/dL',
        normalMin: 0.8,
        normalMax: 1.8,
        referenceText: '0.8–1.8 ng/dL',
        now: now,
        aliases: ['free t4', 'ft4', 't4', 'ثيروكسين'],
      ),
      _seedPdf(
        id: 'pdf_cortisol',
        nameAr: 'الكورتيزول',
        nameEn: 'Cortisol',
        shortCode: 'Cortisol',
        category: 'الهرمونات',
        unit: 'mcg/dL',
        normalMin: 6,
        normalMax: 23,
        referenceText: '6–23 mcg/dL',
        now: now,
        aliases: ['cortisol', 'كورتيزول'],
      ),

      // Vitamins & Minerals
      _seedPdf(
        id: 'pdf_vitamin_d',
        nameAr: 'فيتامين د',
        nameEn: 'Vitamin D',
        shortCode: 'Vit D',
        category: 'الفيتامينات والمعادن',
        unit: 'ng/mL',
        normalMin: 20,
        normalMax: 50,
        referenceText: '20–50 ng/mL',
        now: now,
        aliases: ['vitamin d', 'vit d', '25(oh)d', 'فيتامين د'],
      ),
      _seedPdf(
        id: 'pdf_vitamin_b12',
        nameAr: 'فيتامين ب12',
        nameEn: 'Vitamin B12',
        shortCode: 'B12',
        category: 'الفيتامينات والمعادن',
        unit: 'pg/mL',
        normalMin: 200,
        normalMax: 900,
        referenceText: '200–900 pg/mL',
        now: now,
        aliases: ['vitamin b12', 'b12', 'فيتامين ب12', 'cobalamin'],
      ),
      _seedPdf(
        id: 'pdf_iron',
        nameAr: 'الحديد',
        nameEn: 'Iron',
        shortCode: 'Fe',
        category: 'الفيتامينات والمعادن',
        unit: 'µg/dL',
        normalMin: 60,
        normalMax: 170,
        referenceText: '60–170 µg/dL',
        now: now,
        aliases: ['iron', 'fe', 'حديد', 'serum iron'],
      ),
    ];

    final col = (collectionNameOverride?.trim().isNotEmpty == true)
        ? _db.collection(collectionNameOverride!.trim())
        : _testsCol;
    final batch = _db.batch();
    for (final item in items) {
      batch.set(col.doc(item.id), item.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
    return items.length;
  }

  static TestDefinitionModel _seedPdf({
    required String id,
    required String nameAr,
    required String nameEn,
    required String shortCode,
    required String category,
    required String unit,
    required double? normalMin,
    required double? normalMax,
    required String referenceText,
    required DateTime now,
    required List<String> aliases,
  }) {
    final highText =
        'قد يشير الارتفاع إلى أسباب متعددة ويُنصح بمراجعة الطبيب لتفسير النتيجة حسب الأعراض وباقي التحاليل.';
    final lowText =
        'قد يشير الانخفاض إلى أسباب متعددة ويُنصح بمراجعة الطبيب لتفسير النتيجة حسب الحالة.';

    final arLower = nameAr.toLowerCase();
    final arNorm = _normalizeArabic(arLower);
    final enLower = nameEn.toLowerCase();
    final aliasTokens = aliases
        .map((a) => a.trim().toLowerCase())
        .where((a) => a.isNotEmpty)
        .expand(_tokenize);
    final aliasNormTokens = aliases
        .map((a) => _normalizeArabic(a.trim().toLowerCase()))
        .where((a) => a.isNotEmpty)
        .expand(_tokenize);
    final keywordSet = <String>{
      ..._tokenize(arLower),
      ..._tokenize(arNorm),
      ..._tokenize(enLower),
      ..._tokenize(shortCode.toLowerCase()),
      ...aliasTokens,
      ...aliasNormTokens,
    };

    return TestDefinitionModel(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      shortCode: shortCode,
      nameArLower: arLower,
      nameArNorm: arNorm,
      nameEnLower: enLower,
      keywords: keywordSet.toList()..sort(),
      category: category,
      unit: unit,
      normalMin: normalMin,
      normalMax: normalMax,
      highText: highText,
      lowText: lowText,
      simplifiedExplanation: null,
      referenceText: referenceText,
      updatedAt: now,
      source: 'pdf_300_lab_tests',
      sourceUrl: null,
    );
  }

  static TestDefinitionModel _seed({
    required String id,
    required String nameAr,
    required String nameEn,
    required String shortCode,
    required String category,
    required String unit,
    required double? normalMin,
    required double? normalMax,
    required String highText,
    required String lowText,
    required DateTime now,
    required List<String> aliases,
  }) {
    final arLower = nameAr.toLowerCase();
    final arNorm = _normalizeArabic(arLower);
    final enLower = nameEn.toLowerCase();
    final aliasTokens = aliases
        .map((a) => a.trim().toLowerCase())
        .where((a) => a.isNotEmpty)
        .expand(_tokenize);
    final aliasNormTokens = aliases
        .map((a) => _normalizeArabic(a.trim().toLowerCase()))
        .where((a) => a.isNotEmpty)
        .expand(_tokenize);
    final keywordSet = <String>{
      ..._tokenize(arLower),
      ..._tokenize(arNorm),
      ..._tokenize(enLower),
      ..._tokenize(shortCode.toLowerCase()),
      ...aliasTokens,
      ...aliasNormTokens,
    };
    return TestDefinitionModel(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      shortCode: shortCode,
      nameArLower: arLower,
      nameArNorm: arNorm,
      nameEnLower: enLower,
      keywords: keywordSet.toList()..sort(),
      category: category,
      unit: unit,
      normalMin: normalMin,
      normalMax: normalMax,
      highText: highText,
      lowText: lowText,
      simplifiedExplanation: null,
      referenceText: null,
      updatedAt: now,
      source: null,
      sourceUrl: null,
    );
  }

  static Iterable<String> _tokenize(String s) sync* {
    final cleaned = s.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s]+'), ' ');
    for (final t in cleaned.split(RegExp(r'\s+'))) {
      final token = t.trim();
      if (token.length >= 2) yield token;
    }
  }

  // --- Mayo Clinic Laboratories importer (Test Catalog) ---
  //
  // Note: `www.mayocliniclabs.com` returns HTTP 403 for automated fetches in many environments.
  // The public catalog is accessible via `test.backend.mayocliniclabs.com`.

  static const String _mayoLabsHost = 'test.backend.mayocliniclabs.com';

  Future<int> importMayoLabsTests({
    int limit = 1000,
    Duration delayBetweenRequests = const Duration(milliseconds: 140),
  }) async {
    final siteMapUrl = Uri.https(_mayoLabsHost, '/test-catalog/site-map.php');
    final siteMapHtml = await _fetchText(siteMapUrl);
    final overviewUrls = _extractMayoLabsOverviewLinks(siteMapHtml);
    if (overviewUrls.isEmpty) {
      throw StateError('No Mayo Labs overview links found');
    }

    int imported = 0;
    WriteBatch batch = _db.batch();
    int batchCount = 0;
    final now = DateTime.now();

    for (final url in overviewUrls.take(limit)) {
      final html = await _fetchText(url);
      final plain = _stripHtml(html);

      final title = _extractH1(html)?.trim();
      if (title == null || title.isEmpty) continue;

      final refText = _extractMayoLabsSection(plain, 'Reference Values');
      final parsed = _parseFirstRange(refText ?? '');

      final usefulFor = _extractMayoLabsSection(plain, 'Useful For');
      final interpretation = _extractMayoLabsSection(plain, 'Interpretation');
      final simplified = _compact((usefulFor?.isNotEmpty == true ? usefulFor : interpretation) ?? '', maxChars: 180);

      final docId = _mayoLabsDocId(url);
      if (docId.isEmpty) continue;

      final nameEn = title;
      final nameAr = title; // Mayo Labs doesn't provide Arabic here.
      final arLower = nameAr.toLowerCase();
      final arNorm = _normalizeArabic(arLower);
      final enLower = nameEn.toLowerCase();
      final keywordSet = <String>{
        ..._tokenize(arLower),
        ..._tokenize(arNorm),
        ..._tokenize(enLower),
      };

      final model = TestDefinitionModel(
        id: docId,
        nameAr: nameAr,
        nameEn: nameEn,
        shortCode: _guessShortCode(nameEn),
        nameArLower: arLower,
        nameArNorm: arNorm,
        nameEnLower: enLower,
        keywords: keywordSet.toList()..sort(),
        category: 'تحاليل مخبرية',
        unit: parsed.unit ?? '',
        normalMin: parsed.min,
        normalMax: parsed.max,
        highText: null,
        lowText: null,
        simplifiedExplanation: simplified.isEmpty ? null : simplified,
        referenceText: refText == null ? null : _compact(refText, maxChars: 700),
        updatedAt: now,
        source: 'mayocliniclabs',
        sourceUrl: url.toString(),
      );

      batch.set(_testsCol.doc(model.id), model.toMap(), SetOptions(merge: true));
      batchCount++;
      imported++;

      if (batchCount >= 400) {
        await batch.commit();
        batch = _db.batch();
        batchCount = 0;
      }

      await Future<void>.delayed(delayBetweenRequests);
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    return imported;
  }

  static List<Uri> _extractMayoLabsOverviewLinks(String html) {
    final out = <Uri>[];
    final seen = <String>{};
    final re = RegExp(r'href="([^"]+)"', caseSensitive: false);
    for (final m in re.allMatches(html)) {
      final href = (m.group(1) ?? '').trim();
      if (!href.contains('/test-catalog/overview/')) continue;
      final url = href.startsWith('http')
          ? Uri.parse(href)
          : Uri.https(_mayoLabsHost, href.startsWith('/') ? href : '/$href');
      if (seen.add(url.toString())) out.add(url);
    }
    return out;
  }

  static String _mayoLabsDocId(Uri url) {
    // /test-catalog/overview/8362
    final parts = url.path.split('/').where((p) => p.isNotEmpty).toList();
    final idx = parts.indexOf('overview');
    if (idx == -1 || idx + 1 >= parts.length) return '';
    return 'mcl_${parts[idx + 1]}';
  }

  static String? _extractMayoLabsSection(String plain, String heading) {
    final i = plain.indexOf(heading);
    if (i == -1) return null;
    final tail = plain.substring(i + heading.length);
    final cut = _firstIndexOfAny(tail, const [
      'Useful For',
      'Clinical Information',
      'Interpretation',
      'Cautions',
      'Method Description',
      'Day(s) Performed',
      'Report Available',
      'Fees',
      'CPT Code',
      'LOINC',
      'Test Classification',
    ]);
    final chunk = (cut == -1 ? tail : tail.substring(0, cut)).trim();
    return chunk.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static int _firstIndexOfAny(String s, List<String> needles) {
    int best = -1;
    for (final n in needles) {
      final idx = s.indexOf(n);
      if (idx == -1) continue;
      if (best == -1 || idx < best) best = idx;
    }
    return best;
  }

  static _ParsedRange _parseFirstRange(String refText) {
    final t = refText.replaceAll('\n', ' ');
    final m = RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)\s*([A-Za-z/%µμ0-9\.\-]+)')
        .firstMatch(t);
    if (m == null) return const _ParsedRange();
    return _ParsedRange(
      min: double.tryParse(m.group(1) ?? ''),
      max: double.tryParse(m.group(2) ?? ''),
      unit: (m.group(3) ?? '').trim().isEmpty ? null : (m.group(3) ?? '').trim(),
    );
  }

  static String _compact(String s, {required int maxChars}) {
    final cleaned = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= maxChars) return cleaned;
    return '${cleaned.substring(0, maxChars).trim()}…';
  }

  // --- Mayo Clinic importer (Lab tests only) ---

  static const String _mayoHost = 'www.mayoclinic.org';

  Future<int> importMayoClinicLabTests({
    List<String>? letters,
    int maxToImport = 200,
  }) async {
    final letterList = letters ??
        <String>[
          'A',
          'B',
          'C',
          'D',
          'E',
          'F',
          'G',
          'H',
          'I',
          'J',
          'K',
          'L',
          'M',
          'N',
          'O',
          'P',
          'R',
          'S',
          'T',
          'U',
          'V',
          'W',
          'X',
          '0',
        ];

    final seenUrls = <String>{};
    final candidates = <_MayoCandidate>[];

    for (final letter in letterList) {
      final url = Uri.https(_mayoHost, '/tests-procedures/index', {'letter': letter});
      final html = await _fetchText(url);
      final extracted = _extractIndexLinks(html);
      for (final e in extracted) {
        if (seenUrls.add(e.url.toString())) {
          // Basic heuristic: include anything with "test" in title/link text.
          if (e.title.toLowerCase().contains('test')) {
            candidates.add(e);
          }
        }
      }
      if (candidates.length >= maxToImport) break;
    }

    int imported = 0;
    WriteBatch batch = _db.batch();
    int batchCount = 0;
    final now = DateTime.now();

    for (final c in candidates.take(maxToImport)) {
      final slug = _docIdFromUrl(c.url);
      if (slug.isEmpty) continue;

      // Fetch detail page to confirm it's a lab test (blood/urine) and to get a cleaner title.
      String detailHtml;
      try {
        detailHtml = await _fetchText(c.url);
      } catch (_) {
        // If Mayo blocks detail page fetch, still import minimal info (name + source link).
        detailHtml = '';
      }
      final pageTitle = _extractH1(detailHtml) ?? c.title;
      final lower = pageTitle.toLowerCase();

      final isLab =
          lower.contains('blood test') ||
          lower.contains('urine test') ||
          lower.contains('lab test') ||
          _looksLikeLabTestTitle(lower);
      if (!isLab) continue;

      final nameEn = pageTitle.trim();
      final nameAr = nameEn; // Mayo doesn't provide Arabic; keep same for now.
      final arLower = nameAr.toLowerCase();
      final arNorm = _normalizeArabic(arLower);
      final enLower = nameEn.toLowerCase();
      final keywordSet = <String>{
        ..._tokenize(arLower),
        ..._tokenize(arNorm),
        ..._tokenize(enLower),
      };

      final model = TestDefinitionModel(
        id: slug,
        nameAr: nameAr,
        nameEn: nameEn,
        shortCode: _guessShortCode(nameEn),
        nameArLower: arLower,
        nameArNorm: arNorm,
        nameEnLower: enLower,
        keywords: keywordSet.toList()..sort(),
        category: 'تحاليل مخبرية',
        unit: '',
        normalMin: null,
        normalMax: null,
        highText: null,
        lowText: null,
        simplifiedExplanation: null,
        referenceText: null,
        updatedAt: now,
        source: 'mayoclinic',
        sourceUrl: c.url.toString(),
      );

      batch.set(_testsCol.doc(model.id), model.toMap(), SetOptions(merge: true));
      batchCount++;
      imported++;

      // Firestore batch limit is 500 ops; keep safe.
      if (batchCount >= 400) {
        await batch.commit();
        batch = _db.batch();
        batchCount = 0;
      }

      // Be polite to the origin and reduce throttling risk.
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    return imported;
  }

  static bool _looksLikeLabTestTitle(String lowerTitle) {
    // Exclude obvious non-lab procedures
    const blocked = [
      'surgery',
      'therapy',
      'transplant',
      'ectomy',
      'biopsy',
      'scan',
      'ultrasound',
      'x-ray',
      'mri',
      'ct ',
      'procedure',
    ];
    for (final b in blocked) {
      if (lowerTitle.contains(b)) return false;
    }
    // Include if it ends with "test" or contains common lab patterns.
    if (lowerTitle.endsWith(' test')) return true;
    const labHints = ['level', 'panel', 'count', 'antibody', 'enzyme', 'marker'];
    return labHints.any(lowerTitle.contains);
  }

  static String _guessShortCode(String nameEn) {
    // Pull all-caps tokens like ALT, AST, TSH, etc.
    final m = RegExp(r'\b[A-Z]{2,6}\b').firstMatch(nameEn);
    if (m != null) return m.group(0) ?? '';
    return '';
  }

  static String _docIdFromUrl(Uri url) {
    // Example: /tests-procedures/hemoglobin-test/about/pac-20385075?p=1
    final parts = url.path.split('/').where((p) => p.isNotEmpty).toList();
    final idx = parts.indexOf('tests-procedures');
    if (idx == -1 || idx + 1 >= parts.length) return '';
    final slug = parts[idx + 1];
    return slug.replaceAll(RegExp(r'[^a-z0-9\-]'), '').toLowerCase();
  }

  static Uri _absMayoUrl(String href) {
    if (href.startsWith('http://') || href.startsWith('https://')) {
      return Uri.parse(href);
    }
    if (!href.startsWith('/')) {
      href = '/$href';
    }
    return Uri.https(_mayoHost, href);
  }

  Future<String> _fetchText(Uri url) async {
    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 15);
      final req = await client.getUrl(url);
      req.headers.set('user-agent', 'ai_medical_app/1.0 (Flutter; import)');
      req.headers.set('accept', 'text/html,application/xhtml+xml');
      req.headers.set('accept-language', 'en-US,en;q=0.9');
      final resp = await req.close();
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw HttpException('HTTP ${resp.statusCode}', uri: url);
      }
      final bytes = await resp.fold<List<int>>(<int>[], (a, b) => a..addAll(b));
      return utf8.decode(bytes, allowMalformed: true);
    } finally {
      client.close(force: true);
    }
  }

  static List<_MayoCandidate> _extractIndexLinks(String html) {
    // Extract anchor tags that link into /tests-procedures/...
    final out = <_MayoCandidate>[];
    final re = RegExp(r'<a[^>]+href="([^"]+)"[^>]*>(.*?)</a>', caseSensitive: false, dotAll: true);
    for (final m in re.allMatches(html)) {
      final href = (m.group(1) ?? '').trim();
      if (!href.contains('/tests-procedures/')) continue;
      // Skip index pagination links
      if (href.contains('/tests-procedures/index')) continue;
      final textRaw = (m.group(2) ?? '');
      final title = _stripHtml(textRaw).trim();
      if (title.isEmpty) continue;
      final url = _absMayoUrl(href);
      out.add(_MayoCandidate(title: title, url: url));
    }
    return out;
  }

  static String? _extractH1(String html) {
    final m = RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (m == null) return null;
    final t = _stripHtml(m.group(1) ?? '').trim();
    return t.isEmpty ? null : t;
  }

  static String _stripHtml(String s) {
    final noTags = s.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return noTags.replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _MayoCandidate {
  final String title;
  final Uri url;
  const _MayoCandidate({required this.title, required this.url});
}

class _ParsedRange {
  final double? min;
  final double? max;
  final String? unit;
  const _ParsedRange({this.min, this.max, this.unit});
}
