import json
import os

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # user_guide_screen.dart missing strings
    "follow_simple_steps": {"ar": "اتبع هذه الخطوات البسيطة للاستفادة من جميع ميزات التطبيق", "en": "Follow these simple steps to benefit from all app features"},
    "scan_test": {"ar": "تصوير التحليل", "en": "Scan Test"},
    "click_scan_btn": {"ar": "اضغط على زر تصوير تحليل", "en": "Click on the scan test button"},
    "put_report_in_frame": {"ar": "ضع التقرير داخل الإطار", "en": "Place the report inside the frame"},
    "click_analyze": {"ar": "اضغط تحليل", "en": "Click analyze"},
    "view_results": {"ar": "عرض النتائج", "en": "View Results"},
    "values_shown_with_status": {"ar": "يتم عرض القيم مع الحالة (مرتفع / طبيعي / منخفض)", "en": "Values are shown with status (High / Normal / Low)"},
    "history_tracking": {"ar": "متابعة التاريخ", "en": "History Tracking"},
    "track_previous_tests": {"ar": "يمكنك متابعة تحاليلك السابقة", "en": "You can track your previous tests"},
    "view_as_charts": {"ar": "عرضها في شكل رسوم بيانية", "en": "View them as charts"},
    "manage_medications": {"ar": "إدارة الأدوية", "en": "Manage Medications"},
    "add_medications": {"ar": "إضافة أدوية", "en": "Add medications"},
    "set_reminders": {"ar": "تحديد مواعيد التذكير", "en": "Set reminder times"},
    "link_family_account": {"ar": "ربط حساب عائلي", "en": "Link Family Account"},
    "can_link_family_member": {"ar": "يمكنك ربط حساب أحد أفراد العائلة", "en": "You can link a family member's account"},
    "track_health_results": {"ar": "متابعة نتائجه الصحية", "en": "Track their health results"},
    "important_tip": {"ar": "نصيحة مهمة", "en": "Important Tip"},
    "best_results_tip_desc": {"ar": "للحصول على أفضل النتائج، تأكد من وضوح صورة التحليل والإضاءة الجيدة عند التصوير. استخدم خلفية بلون موحد لتسهيل عملية التحليل.", "en": "For best results, ensure the test image is clear and well-lit when capturing. Use a solid color background to facilitate the analysis process."},
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

print("Translations added via script 2!")
