import '../services/processing_service.dart';

/// One row parsed from OCR (or demo data) before saving to Firestore.
class ParsedLabCandidate {
  final String testName;
  final String nameKey;
  final String subNameKey;
  final double value;
  final String unit;
  final double min;
  final double max;
  final String interpretationKey;
  final String adviceKey;

  ParsedLabCandidate({
    required this.testName,
    required this.nameKey,
    required this.subNameKey,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.interpretationKey,
    required this.adviceKey,
  });

  String get status => ProcessingService.computeStatus(value, min, max);
  String get severity => ProcessingService.computeSeverity(value, min, max);

  Map<String, double> get normalRange => {'min': min, 'max': max};
}
