import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/parsed_lab_candidate.dart';

class AIParseService {
  static final List<String> _endpoints = [
    'http://10.0.2.2:8000/parse-medical-text',   // Android Emulator
    'http://192.168.0.128:8000/parse-medical-text', // Local Network (Physical device)
    'http://127.0.0.1:8000/parse-medical-text',  // iOS Simulator
  ];

  static Future<List<ParsedLabCandidate>> parseHybrid(String text) async {
    List<String> errors = [];
    
    for (String endpoint in _endpoints) {
      try {
        final uri = Uri.parse(endpoint);
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        ).timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final confidence = data['confidence'] as num;
        
        // HYBRID FALLBACK disabled as requested by user.
        if (confidence < 0.3) {
           throw Exception("لم يتعرف الذكاء الاصطناعي على نتائج واضحة (مستوى الثقة منخفض).");
        }

        final tests = data['tests'] as List;
        final results = <ParsedLabCandidate>[];

        for (var t in tests) {
          final testName = t['name'] ?? 'Unknown';
          final value = (t['value'] as num?)?.toDouble() ?? 0.0;
          final unit = t['unit'] ?? '';
          final min = (t['min_range'] as num?)?.toDouble() ?? 0.0;
          final max = (t['max_range'] as num?)?.toDouble() ?? 0.0;
          
          results.add(ParsedLabCandidate(
            testName: testName,
            nameKey: _mapName(testName),
            subNameKey: _mapSubName(testName),
            value: value,
            unit: unit,
            min: min,
            max: max,
            interpretationKey: '${_mapName(testName)}_interpretation',
            adviceKey: '${_mapName(testName)}_advice',
          ));
        }

        if (results.isEmpty) {
          throw Exception("لم يتم العثور على أي تحاليل طبية معروفة في النص الممسوح.");
        }

        return results;
      } else {
        throw Exception("حدث خطأ في الخادم (Backend): رمز الخطأ ${response.statusCode}");
      }
    } catch (e) {
      if (e is Exception && (e.toString().contains("لم يتعرف") || e.toString().contains("لم يتم العثور") || e.toString().contains("حدث خطأ"))) {
        rethrow;
      }
      errors.add("فشل الاتصال بـ $endpoint");
      continue;
    }
  }

  // If all endpoints fail
  throw Exception("تعذر الاتصال بالخادم. الرجاء التأكد من أن مشروع الـ Python يعمل (Backend). $errors");
}

  // Mappers to link the dynamic AI results to the predefined translations
  static String _mapName(String name) {
    final n = name.toLowerCase();
    if (n.contains('glu') || n.contains('sugar')) return 'fasting_sugar';
    if (n.contains('hgb') || n.contains('hemo')) return 'hemoglobin';
    if (n.contains('chol')) return 'cholesterol';
    if (n.contains('vit') && n.contains('d')) return 'vitamin_d';
    return name.replaceAll(' ', '_');
  }

  static String _mapSubName(String name) {
    final n = name.toLowerCase();
    if (n.contains('glu') || n.contains('sugar')) return 'glucose_sub';
    if (n.contains('hgb') || n.contains('hemo')) return 'hemoglobin_sub';
    if (n.contains('chol')) return 'cholesterol_sub';
    if (n.contains('vit') && n.contains('d')) return 'vitamin_d_sub';
    return '${name.replaceAll(' ', '_')}_sub';
  }
}
