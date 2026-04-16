import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "welcome_user": {"ar": "مرحباً أحمد", "en": "Welcome Ahmed"},
    "how_are_you_today": {"ar": "كيف حالك اليوم؟", "en": "How are you today?"},
    "ai_in_medicine": {"ar": "✨ الذكاء الاصطناعي في الطب", "en": "✨ AI in Medicine"},
    "track_health_comprehensively": {"ar": "تتبع صحتك بشكل شامل وسريع", "en": "Track your health comprehensively and quickly"},
    "scan_medical_tests": {"ar": "صور التحاليل الطبية", "en": "Scan Medical Tests"},
    "capture_clear_image_for_analysis": {"ar": "التقط صورة واضحة للحصول على تحليل فوري", "en": "Capture a clear image for instant analysis"},
    "view_details": {"ar": "عرض التفاصيل", "en": "View Details"},
    "alerts_and_reminders": {"ar": "التنبيهات والتذكيرات", "en": "Alerts and Reminders"},
    "medication_time": {"ar": "موعد الدواء", "en": "Medication Time"},
    "bp_med_reminder": {"ar": "حان وقت تناول دواء الضغط - 4:00 مساءً", "en": "It's time to take BP med - 4:00 PM"},
    "test_reminder": {"ar": "تذكير بالتحليل", "en": "Test Reminder"},
    "hba1c_reminder": {"ar": "حان موعد إجراء تحليل السكر التراكمي (HbA1c)", "en": "It's time for your HbA1c test"},
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

print("Translations added for home screen!")
