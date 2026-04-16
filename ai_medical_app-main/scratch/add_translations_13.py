import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Onboarding / Setup
    "welcome_title": {"ar": "أهلاً بك في لابي", "en": "Welcome to Labby"},
    "welcome_subtitle": {"ar": "لنبدأ بإعداد ملفك الشخصي", "en": "Let's start by setting up your profile"},
    "full_name_label": {"ar": "الاسم الكامل", "en": "Full Name"},
    "age_label": {"ar": "العمر", "en": "Age"},
    "gender_label": {"ar": "الجنس", "en": "Gender"},
    "male": {"ar": "ذكر", "en": "Male"},
    "female": {"ar": "أنثى", "en": "Female"},
    "start_btn": {"ar": "ابدأ الآن", "en": "Start Now"},
    
    # Help & Support
    "help_title": {"ar": "المساعدة والدعم", "en": "Help & Support"},
    "contact_us": {"ar": "اتصل بنا", "en": "Contact Us"},
    "faq": {"ar": "الأسئلة الشائعة", "en": "FAQ"},
    "send_message": {"ar": "إرسال رسالة", "en": "Send Message"},
    
    # Terms / Privacy (missing parts)
    "terms_title": {"ar": "شروط الاستخدام", "en": "Terms of Use"},
    "agree_btn": {"ar": "أوافق", "en": "I Agree"},
    
    # Dashboard / Home
    "labby": {"ar": "لابي", "en": "Labby"},
    "tracking_title": {"ar": "التتبع الصحي", "en": "Health Tracking"},
    
    # Chart
    "jan": {"ar": "يناير", "en": "Jan"},
    "feb": {"ar": "فبراير", "en": "Feb"},
    "mar": {"ar": "مارس", "en": "Mar"},
    "apr": {"ar": "أبريل", "en": "Apr"},
    "may": {"ar": "مايو", "en": "May"},
    "jun": {"ar": "يونيو", "en": "Jun"},
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

print("Comprehensive translations added!")
