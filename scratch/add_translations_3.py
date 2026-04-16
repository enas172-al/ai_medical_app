import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "notification_methods": {"ar": "طرق الإشعارات", "en": "Notification Methods"},
    "push_notifications": {"ar": "إشعارات فورية", "en": "Push Notifications"},
    "push_notifications_desc": {"ar": "Push Notifications", "en": "Instant alerts on your device"},
    "email_notifications": {"ar": "البريد الإلكتروني", "en": "Email Notifications"},
    "email_notifications_desc": {"ar": "Email Notifications", "en": "Alerts sent to your email"},
    "disable_all": {"ar": "إيقاف الكل", "en": "Disable All"},
    "enable_all": {"ar": "تفعيل الكل", "en": "Enable All"},
    "important_info": {"ar": "معلومة مهمة", "en": "Important Information"},
    "notification_control_desc": {"ar": "يمكنك التحكم في الإشعارات في أي وقت من الإعدادات. بعض الإشعارات المهمة المتعلقة بالأمان لا يمكن إيقافها.", "en": "You can control notifications anytime from settings. Some important security-related notifications cannot be disabled."},
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

print("Translations added 3!")
