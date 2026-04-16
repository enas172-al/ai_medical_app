import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # Terms of Use Screen
    "terms_subtitle": {"ar": "شروط استخدام التطبيق", "en": "App Terms of Use"},
    "terms_read_carefully": {"ar": "يرجى قراءة هذه الشروط بعناية قبل استخدام التطبيق", "en": "Please read these terms carefully before using the app"},
    "last_update_date": {"ar": "آخر تحديث: 1 أبريل 2026", "en": "Last Update: April 1, 2026"},
    "usage_title": {"ar": "الاستخدام", "en": "Usage"},
    "usage_text": {"ar": "التطبيق مخصص لمساعدة المستخدم في فهم نتائج التحاليل الطبية وتتبعها بسهولة. يجب استخدام التطبيق للأغراض الشخصية فقط.", "en": "The application is intended to help users understand and track medical test results easily. It should be used for personal purposes only."},
    "important_medical_warning": {"ar": "تنبيه طبي مهم", "en": "Important Medical Warning"},
    "not_a_doctor_replacement": {"ar": "التطبيق لا يعتبر بديلاً عن الطبيب المختص.", "en": "The application is not a substitute for a specialist doctor."},
    "consult_doctor_rule": {"ar": "يجب استشارة طبيب مختص في جميع الحالات الطبية", "en": "A specialist doctor must be consulted in all medical cases"},
    "guidance_only_rule": {"ar": "التطبيق يقدم معلومات إرشادية فقط", "en": "The application provides guidance information only"},
    "not_comprehensive_rule": {"ar": "لا يغني التطبيق عن الفحص الطبي الشامل", "en": "The application does not replace a comprehensive medical examination"},
    "accuracy_title": {"ar": "الدقة", "en": "Accuracy"},
    "accuracy_text": {"ar": "يتم تحليل النتائج باستخدام تقنيات الذكاء الاصطناعي المتقدمة، ولكن لا نضمن دقة 100%. قد تحدث أخطاء في قراءة أو تفسير البيانات.", "en": "Results are analyzed using advanced AI, but 100% accuracy is not guaranteed. Errors in data reading or interpretation may occur."},
    "responsibility_title": {"ar": "المسؤولية", "en": "Responsibility"},
    "responsibility_text": {"ar": "المستخدم مسؤول كلياً عن استخدام المعلومات المقدمة من التطبيق.", "en": "The user is fully responsible for using the information provided by the app."},
    "no_liability_rule": {"ar": "لا نتحمل مسؤولية أي قرارات طبية تتخذ بناءً على التطبيق", "en": "We do not assume responsibility for any medical decisions made based on the app"},
    "medical_review_needed_rule": {"ar": "يجب مراجعة الطبيب قبل اتخاذ أي إجراء طبي", "en": "A doctor must be consulted before taking any medical action"},
    "data_accuracy_rule": {"ar": "المستخدم مسؤول عن دقة البيانات التي يدخلها", "en": "The user is responsible for the accuracy of the data they enter"},
    "modifications_title": {"ar": "التعديلات", "en": "Modifications"},
    "modifications_text": {"ar": "نحتفظ بالحق في تحديث شروط الاستخدام في أي وقت. سيتم إشعار المستخدمين بأي تغييرات جوهرية.", "en": "We reserve the right to update terms of use at any time. Users will be notified of any material changes."},
    "by_accepting": {"ar": "بقبولك لهذه الشروط:", "en": "By accepting these terms:"},
    "acknowledge_terms_rule": {"ar": "تقر بأنك قرأت وفهمت جميع الشروط والأحكام", "en": "You acknowledge that you have read and understood all terms and conditions"},
    "agree_usage_rule": {"ar": "توافق على استخدام التطبيق وفقاً لهذه الشروط", "en": "You agree to use the application according to these terms"},
    "full_responsibility_rule": {"ar": "تتحمل المسؤولية الكاملة عن استخدامك للتطبيق", "en": "You bear full responsibility for your use of the application"},
    "important_alert": {"ar": "تنبيه هام ⚠️", "en": "Important Alert ⚠️"},
    "not_medical_diagnosis": {"ar": "هذا التطبيق هو أداة مساعدة فقط ولا يعتبر تشخيصاً طبياً. في حالة وجود أي أعراض أو قلق بشأن صحتك، يجب عليك استشارة طبيب مختص فوراً.", "en": "This app is only a help tool and is not a medical diagnosis. If you have any symptoms or concerns about your health, consult a specialist doctor immediately."},
    "questions_about_terms": {"ar": "أسئلة حول الشروط؟", "en": "Questions about terms?"},
    "contact_support_msg": {"ar": "إذا كان لديك أي استفسار حول شروط الاستخدام، تواصل مع فريق الدعم", "en": "If you have any questions about the terms of use, contact the support team"},
    
    # Chart Related
    "health_charts": {"ar": "الرسوم البيانية الصحية", "en": "Health Charts"},
    "view_trends": {"ar": "عرض اتجاهات نتائجك بمرور الوقت", "en": "View trends of your results over time"},
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

print("Terms and legal translations added!")
