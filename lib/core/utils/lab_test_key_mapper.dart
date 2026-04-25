/// Maps dynamic test names from OCR/LLM to translation keys used in the app.
class LabTestKeyMapper {
  static String nameKey(String name) {
    final n = name.toLowerCase();
    if (n.contains('glu') || n.contains('sugar')) return 'fasting_sugar';
    if (n.contains('hgb') || n.contains('hemo')) return 'hemoglobin';
    if (n.contains('chol')) return 'cholesterol';
    if (n.contains('vit') && n.contains('d')) return 'vitamin_d';
    return name.replaceAll(' ', '_');
  }

  static String subNameKey(String name) {
    final n = name.toLowerCase();
    if (n.contains('glu') || n.contains('sugar')) return 'glucose_sub';
    if (n.contains('hgb') || n.contains('hemo')) return 'hemoglobin_sub';
    if (n.contains('chol')) return 'cholesterol_sub';
    if (n.contains('vit') && n.contains('d')) return 'vitamin_d_sub';
    return '${name.replaceAll(' ', '_')}_sub';
  }
}
