class LabTestDef {
  final String id;
  final String nameKey;
  final String subNameKey;
  final List<String> aliases;
  final String unit;
  final double min;
  final double max;
  final String interpretationKey;
  final String adviceKey;
  final String? explanationHigh;
  final String? explanationLow;
  final double severityMultiplier;

  const LabTestDef({
    required this.id,
    required this.nameKey,
    required this.subNameKey,
    required this.aliases,
    required this.unit,
    required this.min,
    required this.max,
    required this.interpretationKey,
    required this.adviceKey,
    this.explanationHigh,
    this.explanationLow,
    this.severityMultiplier = 1.0,
  });
}

class LabDataset {
  /// قاعدة بيانات التحاليل الرئيسية مع الـ Aliases لمعالجة أخطاء الـ OCR
  static final List<LabTestDef> tests = [
    const LabTestDef(
      id: "GLUCOSE",
      nameKey: "fasting_sugar",
      subNameKey: "glucose_sub",
      aliases: ["glucose", "سكر", "glu", "gluc", "glu cose", "glocose", "blood sugar", "fbs"],
      unit: "mg/dL",
      min: 70,
      max: 100,
      interpretationKey: "glucose_interpretation",
      adviceKey: "glucose_advice",
      explanationHigh: "ارتفاع السكر قد يشير إلى مرض السكري أو مقاومة الإنسولين",
      explanationLow: "انخفاض السكر قد يسبب دوخة أو تعب",
      severityMultiplier: 1.5,
    ),
    const LabTestDef(
      id: "HEMOGLOBIN",
      nameKey: "hemoglobin",
      subNameKey: "hemoglobin_sub",
      aliases: ["hemoglobin", "hgb", "هيموجلوبين", "hb", "haemoglobin"],
      unit: "g/dL",
      min: 13.5,
      max: 17.5,
      interpretationKey: "hemoglobin_interpretation",
      adviceKey: "hemoglobin_advice",
      explanationHigh: "ارتفاع الهيموجلوبين قد يكون بسبب الجفاف أو التدخين",
      explanationLow: "انخفاض الهيموجلوبين دلالة على وجود فقر دم (Anemia)",
    ),
    const LabTestDef(
      id: "CHOLESTEROL",
      nameKey: "cholesterol",
      subNameKey: "cholesterol_sub",
      aliases: ["cholesterol", "كوليسترول", "chol", "total cholesterol", "cholestrol"],
      unit: "mg/dL",
      min: 0,
      max: 200,
      interpretationKey: "cholesterol_interpretation",
      adviceKey: "cholesterol_advice",
    ),
    const LabTestDef(
      id: "VITAMIN_D",
      nameKey: "vitamin_d",
      subNameKey: "vitamin_d_sub",
      aliases: ["vitamin d", "vit d", "فيتامين د", "25-oh", "25(oh)d", "vitd"],
      unit: "ng/mL",
      min: 30,
      max: 100,
      interpretationKey: "vitamin_d_interpretation",
      adviceKey: "vitamin_d_advice",
    ),
    const LabTestDef(
      id: "MCHC",
      nameKey: "MCHC",
      subNameKey: "MCHC_sub",
      aliases: ["mchc", "mean corpuscular hemoglobin concentration"],
      unit: "g/dL",
      min: 31,
      max: 37,
      interpretationKey: "mchc_interpretation",
      adviceKey: "mchc_advice",
    ),
    const LabTestDef(
      id: "MCH",
      nameKey: "MCH",
      subNameKey: "MCH_sub",
      aliases: ["mch", "mean corpuscular hemoglobin"],
      unit: "pg",
      min: 27,
      max: 33,
      interpretationKey: "mch_interpretation",
      adviceKey: "mch_advice",
    ),
    const LabTestDef(
      id: "LYMPHOCYTES",
      nameKey: "Lymphocytes",
      subNameKey: "Lymph_sub",
      aliases: ["lymphocytes", "lym", "lymph", "lymphocyte"],
      unit: "%",
      min: 20,
      max: 40,
      interpretationKey: "lym_interpretation",
      adviceKey: "lym_advice",
    ),
    const LabTestDef(
      id: "WBC",
      nameKey: "WBC",
      subNameKey: "wbc_sub",
      aliases: ["wbc", "white blood cells", "leukocytes", "w b c"],
      unit: "10^3/uL",
      min: 4.0,
      max: 11.0,
      interpretationKey: "wbc_interpretation",
      adviceKey: "wbc_advice",
    ),
    const LabTestDef(
      id: "RBC",
      nameKey: "RBC",
      subNameKey: "rbc_sub",
      aliases: ["rbc", "red blood cells", "erythrocytes", "r b c"],
      unit: "10^6/uL",
      min: 4.5,
      max: 5.9,
      interpretationKey: "rbc_interpretation",
      adviceKey: "rbc_advice",
    ),
    const LabTestDef(
      id: "PLATELETS",
      nameKey: "Platelets",
      subNameKey: "plt_sub",
      aliases: ["platelets", "plt", "thrombocytes", "plat"],
      unit: "10^3/uL",
      min: 150,
      max: 450,
      interpretationKey: "plt_interpretation",
      adviceKey: "plt_advice",
    )
  ];

  /// دالة مفتاحية جداً لمعالجة مشاكل الـ OCR والمسافات والحروف الكبيرة/الصغيرة والرموز الزائدة
  static String normalize(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), "");
  }

  /// خوارزمية Levenshtein لحساب المسافة بين كملتين (أداة سحرية للـ Fuzzy Matching)
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var v0 = List<int>.filled(b.length + 1, 0);
    var v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i <= b.length; i++) v0[i] = i;

    for (int i = 0; i < a.length; i++) {
        v1[0] = i + 1;
        for (int j = 0; j < b.length; j++) {
            int cost = (a[i] == b[j]) ? 0 : 1;
            int minCost = v1[j] + 1; 
            if (v0[j + 1] + 1 < minCost) minCost = v0[j + 1] + 1;
            if (v0[j] + cost < minCost) minCost = v0[j] + cost;
            v1[j + 1] = minCost;
        }
        for (int j = 0; j <= b.length; j++) v0[j] = v1[j];
    }
    return v1[b.length];
  }

  /// استخراج نسبة التطابق بين 0.0 (لا يوجد) و 1.0 (تطابق تام)
  static double _similarity(String a, String b) {
    int distance = _levenshtein(a, b);
    int maxLength = a.length > b.length ? a.length : b.length;
    if (maxLength == 0) return 1.0;
    return 1.0 - (distance / maxLength);
  }

  /// البحث عن التحليل داخل الـ Dataset باستخدام Aliases والـ Fuzzy Matching
  static LabTestDef? findTest(String query) {
    // 1. Minimum Length Filter يمنع الأخطاء الساذجة
    if (query.trim().length < 3) return null;
    
    String normalizedQuery = normalize(query);
    
    LabTestDef? bestMatch;
    double highestSimilarity = 0.0;

    for (var test in tests) {
      for (var alias in test.aliases) {
        String normAlias = normalize(alias);
        
        // 1. بحث دقيق (Exact Match) 
        if (normAlias == normalizedQuery) return test;
        
        // 2. بحث ضمني (Contains Match) لتفادي الكلمات الزائدة
        if (normAlias.length > 2 && normalizedQuery.contains(normAlias)) return test;

        // --- فلتر حماية قوي: Same First Letter Rule ---
        // نمنع ربط الكلمات التي لا تبدأ بنفس الحرف لتفادي CRP vs CPR
        if (normalizedQuery.isNotEmpty && normAlias.isNotEmpty && normalizedQuery[0] != normAlias[0]) {
          continue;
        }

        // 3. بحث ضبابي (Fuzzy Match) لضبط الحروف الناقصة أو الزائدة
        double sim = _similarity(normalizedQuery, normAlias);
        if (sim > highestSimilarity) {
          highestSimilarity = sim;
          bestMatch = test;
        }
      }
    }
    
    // إذا كانت الثقة ضعيفة لا تقبله
    if (highestSimilarity > 0.80) {
      return bestMatch;
    }

    return null;
  }
}
