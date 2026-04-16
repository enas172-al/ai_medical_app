import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "login_title": {"ar": "تسجيل الدخول", "en": "Login"},
    "login_btn": {"ar": "دخول", "en": "Login"},
    "no_account_register": {"ar": "ليس لديك حساب؟ إنشاء حساب", "en": "Don't have an account? Create one"},
    "share_profile_msg": {"ar": "مرحباً، للربط بحسابي في تطبيق Labby، يرجى استخدام الرمز العائلي التالي:\n\n{}", "en": "Hello, to link to my account in Labby app, please use the following family code:\n\n{}"},
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

print("Final translations added!")
