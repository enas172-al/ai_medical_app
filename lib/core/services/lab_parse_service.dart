import '../models/parsed_lab_candidate.dart';

/// Heuristic parsing of OCR text into structured lab lines (no ML).
class LabParseService {
  static double? _extractNumeric(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    for (final kw in keywords) {
      final idx = lower.indexOf(kw.toLowerCase());
      if (idx == -1) continue;
      final end = (idx + 45).clamp(0, lower.length);
      final sub = lower.substring(idx, end);
      final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(sub);
      if (match != null) return double.tryParse(match.group(1)!);
    }
    return null;
  }

  static List<ParsedLabCandidate> parse(String rawText) {
    final text = rawText.toLowerCase();
    final List<ParsedLabCandidate> found = [];

    if (text.contains('glucose') || text.contains('سكر') || text.contains('glu')) {
      final v = _extractNumeric(text, ['glucose', 'سكر', 'glu']) ?? 95;
      found.add(ParsedLabCandidate(
        testName: 'Glucose',
        nameKey: 'fasting_sugar',
        subNameKey: 'glucose_sub',
        value: v,
        unit: 'mg/dL',
        min: 70,
        max: 100,
        interpretationKey: 'glucose_interpretation',
        adviceKey: 'glucose_advice',
      ));
    }

    if (text.contains('hemoglobin') || text.contains('هيموجلوبين') || text.contains('hgb')) {
      final v = _extractNumeric(text, ['hemoglobin', 'hgb', 'هيموجلوبين']) ?? 14.2;
      found.add(ParsedLabCandidate(
        testName: 'Hemoglobin',
        nameKey: 'hemoglobin',
        subNameKey: 'hemoglobin_sub',
        value: v,
        unit: 'g/dL',
        min: 13.5,
        max: 17.5,
        interpretationKey: 'hemoglobin_interpretation',
        adviceKey: 'hemoglobin_advice',
      ));
    }

    if (text.contains('cholesterol') || text.contains('كوليسترول') || text.contains('chol')) {
      final v = _extractNumeric(text, ['cholesterol', 'كوليسترول', 'chol']) ?? 185;
      found.add(ParsedLabCandidate(
        testName: 'Cholesterol',
        nameKey: 'cholesterol',
        subNameKey: 'cholesterol_sub',
        value: v,
        unit: 'mg/dL',
        min: 0,
        max: 200,
        interpretationKey: 'cholesterol_interpretation',
        adviceKey: 'cholesterol_advice',
      ));
    }

    if (text.contains('vitamin d') || text.contains('vit d') || text.contains('فيتامين د')) {
      final v = _extractNumeric(text, ['vitamin d', 'vit d', 'فيتامين د', '25-oh']) ?? 32;
      found.add(ParsedLabCandidate(
        testName: 'Vitamin D',
        nameKey: 'vitamin_d',
        subNameKey: 'vitamin_d_sub',
        value: v,
        unit: 'ng/mL',
        min: 30,
        max: 100,
        interpretationKey: 'vitamin_d_interpretation',
        adviceKey: 'vitamin_d_advice',
      ));
    }

    if (found.isEmpty) return defaultSamples();
    return found;
  }

  static List<ParsedLabCandidate> defaultSamples() {
    return [
      ParsedLabCandidate(
        testName: 'Glucose',
        nameKey: 'fasting_sugar',
        subNameKey: 'glucose_sub',
        value: 95,
        unit: 'mg/dL',
        min: 70,
        max: 100,
        interpretationKey: 'glucose_interpretation',
        adviceKey: 'glucose_advice',
      ),
      ParsedLabCandidate(
        testName: 'Hemoglobin',
        nameKey: 'hemoglobin',
        subNameKey: 'hemoglobin_sub',
        value: 15.2,
        unit: 'g/dL',
        min: 13.5,
        max: 17.5,
        interpretationKey: 'hemoglobin_interpretation',
        adviceKey: 'hemoglobin_advice',
      ),
    ];
  }
}
