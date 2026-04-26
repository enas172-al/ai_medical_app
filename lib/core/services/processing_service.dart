/// Compares lab values to reference ranges and assigns Low / Normal / High.
class ProcessingService {
  static const double _eps = 1e-9;

  static String computeStatus(double value, double min, double max) {
    if (value < min - _eps) return 'Low';
    if (value > max + _eps) return 'High';
    return 'Normal';
  }

  /// يحسب مدى خطورة النتيجة (للمؤشرات الدقيقة)
  static String computeSeverity(double value, double min, double max) {
    if (min >= max) return 'Normal'; // Fallback
    
    // نسبة الخطر (Danger) - أعلى من 50% فوق الطبيعي أو أقل من 50% تحته
    if (value > max * 1.5 || value < min * 0.5) return 'Danger';
    
    // نسبة التحذير (Warning) - أي قيمة خارج النطاق الطبيعي ولم تصل للخطر
    if (value > max || value < min) return 'Warning';
    
    return 'Normal';
  }

  /// Short plain-language line for storage (UI can still use full .tr() strings).
  static String simplifiedExplanation({
    required String testName,
    required String status,
    required String severity,
    required double value,
    required double min,
    required double max,
    required String unit,
  }) {
    switch (status) {
      case 'Low':
        return '$testName is below the typical range ($min–$max $unit). Measured: $value $unit. Severity: $severity.';
      case 'High':
        return '$testName is above the typical range ($min–$max $unit). Measured: $value $unit. Severity: $severity.';
      default:
        return '$testName is within the typical range ($min–$max $unit). Measured: $value $unit.';
    }
  }
}
