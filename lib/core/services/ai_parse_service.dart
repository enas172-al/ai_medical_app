import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/parsed_lab_candidate.dart';
import '../utils/lab_test_key_mapper.dart';
import 'lab_parse_service.dart';
import 'local_llm_service.dart';

class AIParseService {
  static List<Uri> _candidateEndpoints() {
    final out = <Uri>[];

    // 1) Explicit override (best for physical devices)
    final base = AppConfig.backendBaseUrl.trim();
    if (base.isNotEmpty) {
      out.add(Uri.parse('$base/parse-medical-text'));
    }

    // 2) Platform-specific defaults
    if (Platform.isAndroid) {
      // Android emulator -> host machine
      out.add(Uri.parse('http://10.0.2.2:8000/parse-medical-text'));
    }
    // iOS simulator and desktop local runs
    out.add(Uri.parse('http://127.0.0.1:8000/parse-medical-text'));

    // Dedupe while preserving order
    final seen = <String>{};
    return out.where((u) => seen.add(u.toString())).toList(growable: false);
  }

  static Future<List<ParsedLabCandidate>> parseHybrid(String text) async {
    // OCR → optional LLM extraction (Ollama / local LLaMA) → backend → offline heuristics.
    final errors = <String>[];

    if (LocalLLMService.isConfigured) {
      try {
        final fromLlm = await LocalLLMService.extractLabCandidatesFromText(text);
        if (fromLlm.isNotEmpty) {
          return fromLlm;
        }
      } catch (e) {
        errors.add('Ollama extraction: $e');
      }
    }

    for (final uri in _candidateEndpoints()) {
      try {
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
          
          final nk = LabTestKeyMapper.nameKey(testName);
          results.add(ParsedLabCandidate(
            testName: testName,
            nameKey: nk,
            subNameKey: LabTestKeyMapper.subNameKey(testName),
            value: value,
            unit: unit,
            min: min,
            max: max,
            interpretationKey: '${nk}_interpretation',
            adviceKey: '${nk}_advice',
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
      errors.add("فشل الاتصال بـ $uri");
      continue;
    }
  }

  // If all endpoints fail (or no backend provided), do offline parsing.
  final offline = LabParseService.parse(text);
  if (offline.isNotEmpty) return offline;

  throw Exception(
    "ما لقيتش تحاليل واضحة في النصّ الممسوح. "
    "إذا تحب دقّة أكثر: فعّل Backend أو حسّن جودة صورة التحليل. $errors",
  );
}
}
