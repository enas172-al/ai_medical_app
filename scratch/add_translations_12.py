import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Scan Screen
    "scan_title": {"ar": "تصوير التحاليل", "en": "Scan Tests"},
    "scan_instructions": {"ar": "ضع ورقة التحاليل داخل الإطار وتأكد من وضوح النص", "en": "Place the test paper inside the frame and ensure text is clear"},
    
    # Scan Results Screen
    "scan_results_title": {"ar": "نتائج التحاليل", "en": "Test Results"},
    "interpretations_and_advice": {"ar": "التفسيرات والنصائح", "en": "Interpretations & Advice"},
    "medical_interpretation_label": {"ar": "التفسير الطبي", "en": "Medical Interpretation"},
    "advice_and_recommendations_label": {"ar": "النصائح والتوصيات", "en": "Advice & Recommendations"},
    "normal_range_label": {"ar": "المعدل الطبيعي", "en": "Normal Range"},
    "measured_value_label": {"ar": "القيمة المقاسة", "en": "Measured Value"},
    "test_name_col": {"ar": "اسم التحليل", "en": "Test Name"},
    "value_col": {"ar": "القيمة", "en": "Value"},
    "unit_col": {"ar": "الوحدة", "en": "Unit"},
    "normal_range_col": {"ar": "المعدل الطبيعي", "en": "Normal Range"},
    "share": {"ar": "مشاركة", "en": "Share"},
    "save": {"ar": "حفظ", "en": "Save"},
    
    # Interpretations (Detailed)
    "glucose_interpretation": {"ar": "مستوى السكر في الدم ضمن المعدل الطبيعي، مما يشير إلى صحة جيدة لعملية التمثيل الغذائي للجلوكوز.", "en": "Blood sugar level is within normal range, indicating good glucose metabolism health."},
    "glucose_advice": {"ar": "حافظ على نمط حياة صحي مع نظام غذائي متوازن وممارسة الرياضة بانتظام.", "en": "Maintain a healthy lifestyle with a balanced diet and regular exercise."},
    "hemoglobin_interpretation": {"ar": "مستوى الهيموجلوبين طبيعي، مما يعني أن قدرة الدم على نقل الأكسجين جيدة.", "en": "Hemoglobin level is normal, meaning the blood's oxygen-carrying capacity is good."},
    "hemoglobin_advice": {"ar": "استمر في تناول الأطعمة الغنية بالحديد مثل اللحوم الحمراء والخضروات الورقية.", "en": "Continue eating iron-rich foods like red meat and leafy greens."},
    "cholesterol_interpretation": {"ar": "مستوى الكوليسترول أعلى قليلاً من الطبيعي، مما قد يزيد من خطر الإصابة بأمراض القلب والأوعية الدموية.", "en": "Cholesterol level is slightly higher than normal, which may increase cardiovascular disease risk."},
    "cholesterol_advice": {"ar": "يُنصح بتقليل تناول الدهون المشبعة، وزيادة النشاط البدني، واستشارة الطبيب لمتابعة الحالة.", "en": "It is recommended to reduce saturated fat intake, increase physical activity, and consult a doctor for follow-up."},
    "vitamin_d_interpretation": {"ar": "مستوى فيتامين د منخفض، مما قد يؤثر على صحة العظام والجهاز المناعي.", "en": "Vitamin D level is low, which may affect bone and immune system health."},
    "vitamin_d_advice": {"ar": "يُنصح بالتعرض لأشعة الشمس لمدة 15-20 دقيقة يومياً، وتناول مكملات فيتامين د بعد استشارة الطبيب.", "en": "Sun exposure for 15-20 minutes daily and Vitamin D supplements after consulting a doctor are recommended."},
    "wbc_interpretation": {"ar": "تعداد خلايا الدم البيضاء ضمن النطاق الطبيعي، مما يشير إلى وظيفة مناعية جيدة.", "en": "White blood cell count is within normal range, indicating good immune function."},
    "wbc_advice": {"ar": "استمر في اتباع العادات الصحية لتعزيز جهازك المناعي.", "en": "Continue healthy habits to boost your immune system."},
}

for key, val in new_translations.items():
    if key not in ar_data:
        ar_data[key] = val["ar"]
    if key not in en_data:
        en_data[key] = val["en"]

with open(ar_path, 'w', encoding='utf-8') as f:
    json.dump(ar_data, f, ensure_ascii=False, indent=2)

with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, ensure_ascii=False, indent=2)

print("Scan translations added!")
