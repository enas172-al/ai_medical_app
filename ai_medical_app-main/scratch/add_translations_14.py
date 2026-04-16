import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Profile Setup
    "profile_setup_title": {"ar": "إعداد الملف الشخصي", "en": "Profile Setup"},
    "profile_setup_subtitle": {"ar": "أكمل معلوماتك الشخصية للبدء", "en": "Complete your profile info to start"},
    "full_name_hint": {"ar": "أدخل اسمك الكامل", "en": "Enter your full name"},
    "full_name_error": {"ar": "الرجاء إدخال الاسم الكامل", "en": "Please enter your full name"},
    "gender_error": {"ar": "الرجاء اختيار الجنس", "en": "Please select gender"},
    "height_label": {"ar": "الطول (سم)", "en": "Height (cm)"},
    "height_hint": {"ar": "مثال: 170", "en": "Example: 170"},
    "height_error": {"ar": "الرجاء إدخال الطول", "en": "Please enter height"},
    "weight_label": {"ar": "الوزن (كجم)", "en": "Weight (kg)"},
    "weight_hint": {"ar": "مثال: 70", "en": "Example: 70"},
    "weight_error": {"ar": "الرجاء إدخال الوزن", "en": "Please enter weight"},
    "continue_btn": {"ar": "متابعة", "en": "Continue"},
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

print("Setup translations added!")
