import '../models/parsed_lab_candidate.dart';
import '../data/lab_dataset.dart';

/// Advanced parsing of OCR text using generalized line matching (no ML).
class LabParseService {
  static List<ParsedLabCandidate> parse(String rawText) {
    // 1. تقسيم النص
    List<String> lines = rawText.split('\n');

    // 2. تنظيف بسيط
    lines = lines.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    // كلمات الضوضاء التي لا يجب أن تعتبر كأسماء تحاليل
    // (استخدام حدود الكلمات يمنع فلترة كلمات تحتوي جزء منها مثل diagnosis)
    List<String> rejectAsTest = [
      "report", "result", "patient", "name", "date", "test", "age", "sex", "male", "female", 
      "comment", "signature", "dr", "page", "normal", "reference", "range", "unit", "value",
      "reception", "no", "follicular", "ovulation", "luteal", "postmenopausal", "phase"
    ];

    bool isNoise(String text) {
      String lower = text.toLowerCase();
      for (var w in rejectAsTest) {
        if (RegExp('\\b$w\\b').hasMatch(lower)) return true;
      }
      return false;
    }
    
    List<String> tests = [];
    List<double> values = [];
    List<Map<String, double>> ranges = []; // لحفظ (min, max) المستخرجة برمجياً

    // 3. تصنيف السطور
    for (var line in lines) {
      if (line.length > 40) continue; // تجاهل الجمل الطويلة جداً
      
      // أ) السطر يحتوي على اسم ورقم في نفس الوقت
      final fullMatch = RegExp(r'^([a-zA-Z\s\(\)]*[a-zA-Z])\s+(\d+\.?\d*)').firstMatch(line);
      if (fullMatch != null) {
        String tName = fullMatch.group(1)!.trim();
        double val = double.parse(fullMatch.group(2)!);
        
        // لا نضيفها إذا كانت كلمة ضوضاء
        if (tName.length > 2 && !isNoise(tName)) {
          tests.add(tName);
          values.add(val);
          
          // هل يوجد Range في باقي السطر؟
          String rest = line.substring(fullMatch.end);
          var rMatch = RegExp(r'(\d+\.?\d*)\s*-\s*(\d+\.?\d*)').firstMatch(rest);
          if (rMatch != null) {
            ranges.add({
              'min': double.parse(rMatch.group(1)!),
              'max': double.parse(rMatch.group(2)!),
            });
          }
        }
        continue; // تم معالجة السطر بالكامل
      }

      // ب) هل السطر عبارة عن Range معزول؟ (رقم - رقم)
      var rMatch = RegExp(r'^.*?(\d+\.?\d*)\s*-\s*(\d+\.?\d*).*$').firstMatch(line);
      if (rMatch != null) {
        ranges.add({
          'min': double.parse(rMatch.group(1)!),
          'max': double.parse(rMatch.group(2)!),
        });
        continue; 
      }

      // ج) هل السطر عبارة عن رقم فقط؟ 
      var valMatch = RegExp(r'^\s*(\d+\.?\d*)\s*$').firstMatch(line);
      if (valMatch != null) {
        double val = double.parse(valMatch.group(1)!);
        // فلترة أرقام تعريفية غريبة مثل 93181
        if (val < 10000) {
          values.add(val);
        }
        continue;
      }

      // د) هل السطر عبارة عن اسم تحليل فقط؟ 
      // تم تخفيف الصرامة للسماح بالأرقام والنقاط مثل Vitamin B12 و W.B.C و HbA1c
      if (RegExp(r'^[a-zA-Z0-9\s\(\)\.\-\%]+$').hasMatch(line) && line.length > 2) {
        String tName = line.trim();
        if (!isNoise(tName)) {
          tests.add(tName);
        }
      }
    }

    // 4. الربط والاستخراج 
    List<ParsedLabCandidate> candidates = [];
    int len = tests.length < values.length ? tests.length : values.length;

    for (int i = 0; i < len; i++) {
        double val = values[i];
        
        // --- Validation Layer (قيم غير معقولة يتم رفضها) ---
        if (val < 0 || val > 10000) continue;

        Map<String, double>? currentRange;
        if (i < ranges.length) {
            currentRange = ranges[i];
            
            // --- Validation Layer (نطاق طبيعي خاطئ) ---
            if (currentRange['min']! >= currentRange['max']!) {
               currentRange = null; // تجاهل هذا النطاق، وسيعتمد على ال Dataset
            }
        }
        
        candidates.add(_createCandidate(tests[i], val, dynamicRange: currentRange));
    }

    return candidates;
  }

  static ParsedLabCandidate _createCandidate(String testName, double value, {Map<String, double>? dynamicRange}) {
    // نبحث عن التحليل في الداتا سيت الخاصة بنا
    final matchedDef = LabDataset.findTest(testName);
    
    // قيم افتراضية قوية مدعومة بقيم مستخرجة من الورقة (إن وُجدت) أو من ال Dataset
    double min = dynamicRange?['min'] ?? matchedDef?.min ?? 0.0;
    double max = dynamicRange?['max'] ?? matchedDef?.max ?? 100.0;
    String unit = matchedDef?.unit ?? '';
    
    String nameKey = matchedDef?.nameKey ?? testName;
    String subNameKey = matchedDef?.subNameKey ?? '${testName}_sub';
    String intKey = matchedDef?.interpretationKey ?? '${testName}_interpretation';
    String advKey = matchedDef?.adviceKey ?? '${testName}_advice';

    return ParsedLabCandidate(
      testName: testName,
      nameKey: nameKey,
      subNameKey: subNameKey,
      value: value,
      unit: unit,
      min: min,
      max: max,
      interpretationKey: intKey,
      adviceKey: advKey,
    );
  }
}
