import 'package:cloud_firestore/cloud_firestore.dart';

class TestDefinitionModel {
  final String id;

  /// Display names
  final String nameAr;
  final String nameEn;
  final String shortCode; // e.g. "ALT", "WBC", "Glucose"

  /// Search helpers
  final String nameArLower;
  final String? nameArNorm; // Arabic normalized (e.g. إنزيم -> انزيم)
  final String nameEnLower;
  final List<String> keywords; // lowercase tokens + aliases

  /// Classification & ranges
  final String category; // localized category label or a stable key (kept simple for now)
  final String unit;
  final double? normalMin;
  final double? normalMax;

  /// Explanations (optional)
  final String? highText;
  final String? lowText;
  final String? simplifiedExplanation; // short plain-language summary
  final String? referenceText; // full reference values text (may include age/sex)

  /// Audit
  final DateTime? updatedAt;
  final String? source; // e.g. "mayoclinic"
  final String? sourceUrl;

  const TestDefinitionModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.shortCode,
    required this.nameArLower,
    required this.nameArNorm,
    required this.nameEnLower,
    required this.keywords,
    required this.category,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
    required this.highText,
    required this.lowText,
    required this.simplifiedExplanation,
    required this.referenceText,
    required this.updatedAt,
    required this.source,
    required this.sourceUrl,
  });

  factory TestDefinitionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return TestDefinitionModel(
      id: doc.id,
      nameAr: (data['nameAr'] ?? '').toString(),
      nameEn: (data['nameEn'] ?? '').toString(),
      shortCode: (data['shortCode'] ?? '').toString(),
      nameArLower: (data['nameArLower'] ?? '').toString(),
      nameArNorm: data['nameArNorm']?.toString(),
      nameEnLower: (data['nameEnLower'] ?? '').toString(),
      keywords: List<String>.from(data['keywords'] ?? const <String>[]),
      category: (data['category'] ?? '').toString(),
      unit: (data['unit'] ?? '').toString(),
      normalMin: (data['normalMin'] is num) ? (data['normalMin'] as num).toDouble() : null,
      normalMax: (data['normalMax'] is num) ? (data['normalMax'] as num).toDouble() : null,
      highText: data['highText']?.toString(),
      lowText: data['lowText']?.toString(),
      simplifiedExplanation: data['simplifiedExplanation']?.toString(),
      referenceText: data['referenceText']?.toString(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as dynamic).toDate() as DateTime : null,
      source: data['source']?.toString(),
      sourceUrl: data['sourceUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'shortCode': shortCode,
      'nameArLower': nameArLower,
      'nameArNorm': nameArNorm,
      'nameEnLower': nameEnLower,
      'keywords': keywords,
      'category': category,
      'unit': unit,
      'normalMin': normalMin,
      'normalMax': normalMax,
      'highText': highText,
      'lowText': lowText,
      'simplifiedExplanation': simplifiedExplanation,
      'referenceText': referenceText,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'source': source,
      'sourceUrl': sourceUrl,
    };
  }
}

