import 'package:cloud_firestore/cloud_firestore.dart';

class AnalysisModel {
  final String? id;
  final String userId;
  final String testName;
  final double value;
  final String unit;
  final Map<String, double> normalRange; // {'min': 12, 'max': 16}
  final String status; // 'Low', 'Normal', 'High'
  final DateTime date;
  final String? imageUrl;
  final String? simplifiedExplanation;

  AnalysisModel({
    this.id,
    required this.userId,
    required this.testName,
    required this.value,
    this.unit = '',
    required this.normalRange,
    required this.status,
    required this.date,
    this.imageUrl,
    this.simplifiedExplanation,
  });

  factory AnalysisModel.fromMap(Map<String, dynamic> map, String id) {
    return AnalysisModel(
      id: id,
      userId: map['userId'] ?? '',
      testName: map['testName'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      normalRange: Map<String, double>.from(map['normalRange'] ?? {}),
      status: map['status'] ?? 'Normal',
      date: map['date'] != null ? (map['date'] as dynamic).toDate() : DateTime.now(),
      imageUrl: map['imageUrl'],
      simplifiedExplanation: map['simplifiedExplanation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'testName': testName,
      'value': value,
      'unit': unit,
      'normalRange': normalRange,
      'status': status,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'simplifiedExplanation': simplifiedExplanation,
    };
  }
}
