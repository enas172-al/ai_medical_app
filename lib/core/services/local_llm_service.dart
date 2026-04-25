import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/parsed_lab_candidate.dart';
import '../utils/lab_test_key_mapper.dart';
import 'processing_service.dart';

class LocalLLMService {
  static Uri _generateUri() {
    final base = AppConfig.ollamaBaseUrl.trim();
    return Uri.parse('${base.isEmpty ? 'http://127.0.0.1:11434' : base}/api/generate');
  }

  static bool get isConfigured => AppConfig.ollamaModel.trim().isNotEmpty;

  /// Parses a reference range string into [min, max]. Unknown → wide band so status stays neutral.
  static ({double min, double max}) _minMaxFromRange(String? range) {
    if (range == null) return (min: 0.0, max: 1e9);
    final s = range
        .trim()
        .replaceAll('–', '-')
        .replaceAll('—', '-')
        .replaceAll(RegExp(r'\s+to\s+', caseSensitive: false), '-')
        .replaceAll('٫', '.');
    final m = RegExp(r'([\d.,]+)\s*-\s*([\d.,]+)').firstMatch(s);
    if (m == null) return (min: 0.0, max: 1e9);
    double? p(String x) => double.tryParse(x.replaceAll(',', '.'));
    final a = p(m.group(1)!);
    final b = p(m.group(2)!);
    if (a == null || b == null) return (min: 0.0, max: 1e9);
    final lo = a <= b ? a : b;
    final hi = a <= b ? b : a;
    if (hi - lo < 1e-12) return (min: 0.0, max: 1e9);
    return (min: lo, max: hi);
  }

  static String _stripCodeFences(String raw) {
    var s = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```', caseSensitive: false);
    final m = fence.firstMatch(s);
    if (m != null) {
      s = m.group(1)!.trim();
    }
    return s;
  }

  /// Structured extraction only (no diagnosis). Output is validated; [ProcessingService] still decides Low/Normal/High.
  static Future<List<ParsedLabCandidate>> extractLabCandidatesFromText(
    String text, {
    Duration timeout = const Duration(seconds: 120),
  }) async {
    if (!isConfigured) {
      throw Exception('مودل Ollama مش مهيّأ. زِد `--dart-define=OLLAMA_MODEL=...`.');
    }
    final t = text.trim();
    if (t.isEmpty) return [];

    final prompt = '''
You extract lab test rows from OCR/plain text. Extraction only — do not diagnose, advise, or invent numbers.

Return ONLY a JSON array. Each element must be an object with keys:
- "test" (string): test name as in the text
- "value" (number): measured value
- "unit" (string): unit or "" if none
- "range" (string or null): reference like "4.0-11.0" if present, else null

Rules:
- Use numbers that appear in the text; never guess missing values.
- If there are no lab lines, return [].
- No markdown, no commentary — only the JSON array.

Text:
$t
''';

    final res = await http
        .post(
          _generateUri(),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': AppConfig.ollamaModel.trim(),
            'prompt': prompt,
            'stream': false,
            'options': {
              'temperature': 0.1,
            }
          }),
        )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('فشل الاتصال بـ Ollama (HTTP ${res.statusCode}).');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final responseRaw = (data['response'] as String?)?.trim();
    if (responseRaw == null || responseRaw.isEmpty) {
      throw Exception('Ollama رجّع نتيجة فارغة.');
    }

    final jsonStr = _stripCodeFences(responseRaw);
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) {
      throw Exception('النموذج لم يرجع مصفوفة JSON صالحة.');
    }

    final out = <ParsedLabCandidate>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final testName = (m['test'] ?? m['name'] ?? '').toString().trim();
      if (testName.isEmpty) continue;

      final num? vNum = m['value'] is num
          ? m['value'] as num
          : num.tryParse(m['value']?.toString() ?? '');
      if (vNum == null || !vNum.isFinite) continue;
      final value = vNum.toDouble();

      final unit = (m['unit'] ?? '').toString().trim();
      final rangeStr = m['range']?.toString();
      final mm = _minMaxFromRange(rangeStr);

      final nk = LabTestKeyMapper.nameKey(testName);
      out.add(ParsedLabCandidate(
        testName: testName,
        nameKey: nk,
        subNameKey: LabTestKeyMapper.subNameKey(testName),
        value: value,
        unit: unit,
        min: mm.min,
        max: mm.max,
        interpretationKey: '${nk}_interpretation',
        adviceKey: '${nk}_advice',
      ));
    }

    return out;
  }

  /// Returns an Arabic plain-text explanation. This is "interpretation only":
  /// - no final diagnosis
  /// - no medication prescriptions or dosages
  static Future<String> explainCandidates({
    required List<ParsedLabCandidate> candidates,
    String? patientContext,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (candidates.isEmpty) return '';
    if (!isConfigured) {
      throw Exception('مودل Ollama مش مهيّأ. زِد `--dart-define=OLLAMA_MODEL=...`.');
    }

    final rows = candidates
        .map((c) => {
              'name': c.testName,
              'value': c.value,
              'unit': c.unit,
              'reference_range': {'min': c.min, 'max': c.max},
              'status': ProcessingService.computeStatus(c.value, c.min, c.max),
            })
        .toList(growable: false);

    final prompt = '''
أنت مساعد طبي للتفسير فقط، موش للتشخيص.
اعتمد فقط على JSON التالي (تحاليل + وحدات + reference ranges + status).
ممنوع:
- تشخيص نهائي (مثل "عندك مرض X")
- وصف أدوية أو جرعات

أكتب الإجابة بالعربية (واضحة وبنقاط) وبالترتيب:
1) ملخص بسيط
2) شنوّة غير طبيعي؟ (High/Low)
3) أسباب محتملة شائعة (مع التأكيد أنها ليست تشخيص)
4) أسئلة لازم نسألهم للطبيب
5) علامات خطر تستوجب استعجال

سياق إضافي (قد يكون فارغ):
${patientContext?.trim().isNotEmpty == true ? patientContext!.trim() : '-'}

JSON:
${jsonEncode(rows)}
''';

    final res = await http
        .post(
          _generateUri(),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': AppConfig.ollamaModel.trim(),
            'prompt': prompt,
            'stream': false,
            'options': {
              'temperature': 0.2,
            }
          }),
        )
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw Exception('فشل الاتصال بـ Ollama (HTTP ${res.statusCode}).');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final response = (data['response'] as String?)?.trim();
    if (response == null || response.isEmpty) {
      throw Exception('Ollama رجّع نتيجة فارغة.');
    }
    return response;
  }
}

