import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "dashboard_title": {"ar": "لوحة التحكم الصحية", "en": "Health Dashboard"},
    "new_result": {"ar": "نتيجة جديدة", "en": "New Result"},
    "analysis_success": {"ar": "تم تحليل نتائجك بنجاح", "en": "Your results analyzed successfully"},
    "view_all_notifications": {"ar": "عرض جميع الإشعارات", "en": "View all notifications"},
    "all_notifications": {"ar": "كل الإشعارات", "en": "All Notifications"},
    "family_member_tag": {"ar": "عضو في العائلة", "en": "Family Member"},
    "my_account_tag": {"ar": "حسابي", "en": "My Account"},
    "companion_role": {"ar": "مرافق", "en": "Companion"},
    "since_5_minutes": {"ar": "منذ 5 دقائق", "en": "5 minutes ago"},
    "since_1_hour": {"ar": "منذ ساعة", "en": "1 hour ago"},
    "since_3_hours": {"ar": "منذ 3 ساعات", "en": "3 hours ago"},
    "bp_med_reminder_simple": {"ar": "حان وقت تناول دواء الضغط", "en": "It's time to take your blood pressure medication"},
    "hba1c_reminder_simple": {"ar": "حان موعد إجراء تحليل السكر التراكمي", "en": "It's time for your HbA1c test"},
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

print("Translations added for dashboard and notifications!")
