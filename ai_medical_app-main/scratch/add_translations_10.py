import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Search Screen
    "search_tests_title": {"ar": "بحث عن التحاليل", "en": "Search for Tests"},
    "search_tests_subtitle": {"ar": "اكتشف معاني التحاليل والقيم الطبيعية", "en": "Discover test meanings and normal values"},
    "search_tests_hint": {"ar": "ابحث عن تحليل...", "en": "Search for a test..."},
    
    # Categories
    "cat_sugars": {"ar": "السكريات", "en": "Sugars"},
    "cat_blood": {"ar": "الدم", "en": "Blood"},
    "cat_fats": {"ar": "الدهون", "en": "Fats"},
    "cat_vitamins": {"ar": "الفيتامينات", "en": "Vitamins"},
    "cat_kidney": {"ar": "الكلى", "en": "Kidney"},
    "cat_liver": {"ar": "الكبد", "en": "Liver"},

    # Test Details (Search)
    "glucose_high_desc": {"ar": "قد يشير إلى مرض السكري أو مقاومة الأنسولين.", "en": "May indicate diabetes or insulin resistance."},
    "glucose_low_desc": {"ar": "قد يدل على انخفاض السكر ويحتاج تدخل سريع.", "en": "May indicate hypoglycemia and needs quick intervention."},
    "hemoglobin_high_desc": {"ar": "قد يدل على الجفاف أو أمراض الدم.", "en": "May indicate dehydration or blood disorders."},
    "hemoglobin_low_desc": {"ar": "قد يشير إلى فقر الدم (أنيميا).", "en": "May indicate anemia."},
    "cholesterol_high_desc": {"ar": "يزيد خطر أمراض القلب.", "en": "Increases risk of heart disease."},
    "cholesterol_low_desc": {"ar": "نادراً ما يكون منخفض ويشير لسوء تغذية.", "en": "Rarely low and may indicate malnutrition."},
    "vitamin_d_high_desc": {"ar": "قد يسبب ضعف العظام.", "en": "May cause bone weakness."},
    "vitamin_d_low_desc": {"ar": "قد يؤدي إلى مشاكل في امتصاص الكالسيوم.", "en": "May lead to calcium absorption problems."},
    "creatinine_high_desc": {"ar": "قد يدل على ضعف وظائف الكلى.", "en": "May indicate weak kidney function."},
    "creatinine_low_desc": {"ar": "نادراً ما يكون منخفض.", "en": "Rarely low."},
    "alt_high_desc": {"ar": "قد يشير إلى التهاب الكبد.", "en": "May indicate hepatitis."},
    "alt_low_desc": {"ar": "غالباً لا يكون له دلالة مهمة.", "en": "Usually has no significant meaning."},
    "wbc_high_desc": {"ar": "قد يدل على وجود عدوى.", "en": "May indicate an infection."},
    "wbc_low_desc": {"ar": "قد يشير إلى ضعف المناعة.", "en": "May indicate weak immunity."},
    "platelets_high_desc": {"ar": "قد يسبب جلطات.", "en": "May cause clots."},
    "platelets_low_desc": {"ar": "قد يسبب نزيف.", "en": "May cause bleeding."},

    # History Screen
    "history_title": {"ar": "سجل التحاليل", "en": "Test History"},
    "user_history_title": {"ar": "سجل تحاليل {}", "en": "{}'s Test History"},
    "history_subtitle": {"ar": "جميع تحاليلك السابقة في مكان واحد", "en": "All your previous tests in one place"},
    "all_tests_tab": {"ar": "جميع التحاليل", "en": "All Tests"},
    "latest_tab": {"ar": "الأحدث", "en": "Latest"},
    "you_are_tracking": {"ar": "أنت تتابع", "en": "You are tracking"},
    "results_count": {"ar": "{} نتيجة", "en": "{} results"},
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

print("Search and History translations added!")
