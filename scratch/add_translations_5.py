import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "privacy_policy_title": {"ar": "سياسة الخصوصية", "en": "Privacy Policy"},
    "privacy_priority": {"ar": "خصوصيتك تهمنا", "en": "Your Privacy Matters"},
    "privacy_guarantee": {"ar": "نحن ملتزمون بحماية بياناتك الصحية وخصوصيتك", "en": "We are committed to protecting your health data and privacy"},
    "last_update": {"ar": "آخر تحديث: 1 أبريل 2026", "en": "Last Update: April 1, 2026"},
    "data_collection": {"ar": "جمع البيانات", "en": "Data Collection"},
    "data_collection_desc": {"ar": "نقوم بجمع بيانات التحاليل الطبية التي يقوم المستخدم بإدخالها أو تصويرها فقط. لا نجمع أي بيانات إضافية بدون موافقتك الصريحة.", "en": "We only collect medical analysis data that the user enters or captures. We do not collect any additional data without your explicit consent."},
    "data_usage": {"ar": "استخدام البيانات", "en": "Data Usage"},
    "data_usage_desc": {"ar": "تستخدم البيانات لتحليل النتائج وتقديم نصائح صحية ذكية تساعدك في فهم حالتك الصحية.", "en": "Data is used to analyze results and provide smart health tips to help you understand your health status."},
    "no_commercial_usage": {"ar": "لا يتم استخدام البيانات لأي أغراض تجارية", "en": "Data is not used for any commercial purposes"},
    "no_selling_data": {"ar": "لا يتم بيع بياناتك لأطراف ثالثة", "en": "Your data is not sold to third parties"},
    "data_ownership": {"ar": "تبقي بياناتك ملكاً خاصاً لك", "en": "Your data remains your private property"},
    "data_protection": {"ar": "حماية البيانات", "en": "Data Protection"},
    "data_protection_desc": {"ar": "نلتزم بأعلى معايير الأمان لحماية بياناتك الصحية.", "en": "We adhere to the highest security standards to protect your health data."},
    "data_encryption": {"ar": "يتم تشفير جميع البيانات", "en": "All data is encrypted"},
    "secure_servers": {"ar": "يتم حفظ البيانات بشكل آمن على خوادم محمية", "en": "Data is stored securely on protected servers"},
    "no_sharing": {"ar": "لا يتم مشاركة البيانات مع أي طرف ثالث", "en": "Data is not shared with any third party"},
    "user_consent": {"ar": "موافقة المستخدم", "en": "User Consent"},
    "user_consent_desc": {"ar": "باستخدام التطبيق، يوافق المستخدم على سياسة الخصوصية هذه. يمكنك حذف بياناتك في أي وقت من إعدادات الملف الشخصي.", "en": "By using the app, the user agrees to this privacy policy. You can delete your data at any time from the profile settings."},
    "your_rights": {"ar": "حقوقك", "en": "Your Rights"},
    "right_to_access": {"ar": "حق الوصول", "en": "Right to Access"},
    "right_to_access_desc": {"ar": "يمكنك الوصول إلى جميع بياناتك في أي وقت", "en": "You can access all your data at any time"},
    "right_to_edit": {"ar": "حق التعديل", "en": "Right to Edit"},
    "right_to_edit_desc": {"ar": "يمكنك تعديل أو تحديث بياناتك في أي وقت", "en": "You can edit or update your data at any time"},
    "right_to_delete": {"ar": "حق الحذف", "en": "Right to Delete"},
    "right_to_delete_desc": {"ar": "يمكنك حذف جميع بياناتك نهائياً من التطبيق", "en": "You can delete all your data permanently from the app"},
    "have_questions": {"ar": "هل لديك أسئلة؟", "en": "Have Questions?"},
    "privacy_questions_desc": {"ar": "إذا كان لديك أي استفسار حول سياسة الخصوصية، لا تتردد في التواصل معنا", "en": "If you have any questions about the privacy policy, please feel free to contact us"},
    "contact_us": {"ar": "تواصل معنا", "en": "Contact Us"},
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

print("Translations added for privacy policy!")
