/// Compares lab values to reference ranges and assigns Low / Normal / High.
class ProcessingService {
  static const double _eps = 1e-9;

  static String computeStatus(double value, double min, double max) {
    if (value < min - _eps) return 'Low';
    if (value > max + _eps) return 'High';
    return 'Normal';
  }

  /// Short plain-language line for storage (UI can still use full .tr() strings).
  static String simplifiedExplanation({
    required String testName,
    required String status,
    required double value,
    required double min,
    required double max,
    required String unit,
  }) {
    switch (status) {
      case 'Low':
        return '$testName is below the typical range ($min–$max $unit). Measured: $value $unit.';
      case 'High':
        return '$testName is above the typical range ($min–$max $unit). Measured: $value $unit.';
      default:
        return '$testName is within the typical range ($min–$max $unit). Measured: $value $unit.';
    }
  }
}
