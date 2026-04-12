import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Medication Screen
    "medications_title": {"ar": "الأدوية والمكملات", "en": "Medications & Supplements"},
    "user_medications_title": {"ar": "أدوية {}", "en": "{}'s Medications"},
    "medications_subtitle": {"ar": "تتبع مواعيد أدويتك ومكملاتك الغذائية", "en": "Track your medication and supplement timings"},
    "add_new_med": {"ar": "إضافة دواء جديد", "en": "Add New Medication"},
    "confirm_delete": {"ar": "تأكيد الحذف", "en": "Confirm Delete"},
    "confirm_delete_msg": {"ar": "هل أنت متأكد من حذف هذا الدواء؟", "en": "Are you sure you want to delete this medication?"},
    "no_meds": {"ar": "لا توجد أدوية", "en": "No medications found"},
    "am": {"ar": "صباحاً", "en": "AM"},
    "pm": {"ar": "مساءً", "en": "PM"},
    "daily": {"ar": "يومياً", "en": "Daily"},
    "three_times_daily": {"ar": "ثلاث مرات يومياً", "en": "Three times daily"},
    "anonymous_user": {"ar": "مجهول", "en": "Anonymous"},
    "switch_account_btn": {"ar": "تبديل الحساب", "en": "Switch Account"},
    "link_request_sent": {"ar": "تم إرسال طلب الربط بنجاح", "en": "Link request sent successfully"},
    
    # Common Med Names
    "med_aspirin": {"ar": "أسبرين", "en": "Aspirin"},
    "med_metformin": {"ar": "ميتفورمين", "en": "Metformin"},
    "med_vitamin_d": {"ar": "فيتامين د", "en": "Vitamin D"},
    "med_nubain": {"ar": "نوبين", "en": "Nubain"},
    "med_vitamin_c": {"ar": "فيتامين سي", "en": "Vitamin C"},
    "med_omega3": {"ar": "أوميجا 3", "en": "Omega 3"},
    
    # Common Doses/Units
    "dose_mg": {"ar": "{} ملغ", "en": "{} mg"},
    "dose_units": {"ar": "{} وحدة", "en": "{} units"},
    "dose_capsule": {"ar": "كبسولة واحدة", "en": "One capsule"},
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

print("Medication translations added!")
