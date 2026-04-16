import json
import os

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    # register_screen.dart
    "your_health_companion": {"ar": "رفيقك في رحلة الصحة", "en": "Your Health Companion"},
    "create_new_account": {"ar": "إنشاء حساب جديد", "en": "Create a New Account"},
    "enter_your_name": {"ar": "أدخل اسمك", "en": "Enter your name"},
    "password": {"ar": "كلمة المرور", "en": "Password"},
    "family_code_optional": {"ar": "كود العائلة (اختياري)", "en": "Family Code (Optional)"},
    "enter_family_code_to_link": {"ar": "أدخل كود العائلة للربط", "en": "Enter family code to link"},
    "link_family_desc": {"ar": "يمكنك ربط حسابك مع أفراد العائلة لمشاركة النتائج", "en": "You can link your account with family members to share results"},
    "create_account_btn": {"ar": "إنشاء حساب", "en": "Create Account"},
    "already_have_account_login": {"ar": "لديك حساب؟ تسجيل الدخول", "en": "Already have an account? Login"},
    
    # user_guide_screen.dart
    "user_guide_title": {"ar": "دليل المستخدم", "en": "User Guide"},
    "getting_started": {"ar": "مقدمة للبدء", "en": "Getting Started"},
    "getting_started_desc": {"ar": "تطبيق Labby هو رفيقك الشخصي لتحليل وقراءة نتائج التحاليل الطبية باستخدام الذكاء الاصطناعي لتسهيل فهم حالتك الصحية.", "en": "Labby app is your personal companion to analyze and read medical test results using AI to facilitate understanding your health status."},
    "how_to_use_app": {"ar": "كيف تستخدم التطبيق؟", "en": "How to Use the App?"},
    "step_1": {"ar": "1. الإضافة والتحليل", "en": "1. Add and Analyze"},
    "step_1_desc": {"ar": "اضغط على أيقونة الكاميرا في الصفحة الرئيسية لتصوير نتيجة التحليل أو رفع الصورة من المعرض. سيقوم التطبيق بتحليل النتائج خلال ثوانٍ.", "en": "Click the camera icon on the homepage to take a picture of the test result or upload an image from the gallery. The app will analyze the results in seconds."},
    "step_2": {"ar": "2. فهم النتائج", "en": "2. Understand Results"},
    "step_2_desc": {"ar": "ستحصل على قراءة مبسطة للنتائج مبينة بالألوان (مرتفع، منخفض، طبيعي) مع نصائح مخصصة بناءً على حالتك.", "en": "You will get a simplified reading of the results indicated by colors (High, Low, Normal) along with personalized tips based on your condition."},
    "step_3": {"ar": "3. المتابعة الصحية", "en": "3. Health Tracking"},
    "step_3_desc": {"ar": "تابع التغيرات في نتائجك عبر الزمن من خلال الرسوم البيانية في لوحة التحكم لمراقبة تطور حالتك.", "en": "Track changes in your results over time through charts in the dashboard to monitor the progress of your condition."},
    "step_4": {"ar": "4. نظام العائلة", "en": "4. Family System"},
    "step_4_desc": {"ar": "يمكنك إضافة أفراد عائلتك ومتابعة تحاليلهم من حسابك الشخصي بكل سهولة.", "en": "You can add your family members and track their tests from your personal account easily."},
    "important_notes": {"ar": "ملاحظات هامة", "en": "Important Notes"},
    "note_1": {"ar": "• نتائج الذكاء الاصطناعي لا تغني عن استشارة الطبيب المختص.", "en": "• AI results are not a substitute for consulting a specialized doctor."},
    "note_2": {"ar": "• تأكد من وضوح الصورة عند التقاطها لضمان دقة التحليل.", "en": "• Ensure the image is clear when taken to guarantee accurate analysis."},
    "note_3": {"ar": "• يتم حفظ بياناتك الطبية بسرية تامة ومحفوظة بأعلى درجات الأمان.", "en": "• Your medical data is kept strictly confidential and secured with the highest levels of security."},
    "start_using_app": {"ar": "ابدأ استخدام التطبيق", "en": "Start Using App"},
    
    # notification_settings_screen.dart
    "notification_settings_title": {"ar": "إعدادات الإشعارات", "en": "Notification Settings"},
    "general_notifications": {"ar": "الإشعارات العامة", "en": "General Notifications"},
    "test_results_alerts": {"ar": "تنبيهات نتائج التحاليل", "en": "Test Results Alerts"},
    "test_results_desc": {"ar": "إشعار عند الانتهاء من تحليل نتائجك", "en": "Notification when analysis of your results is complete"},
    "health_reminders": {"ar": "تذكيرات صحية", "en": "Health Reminders"},
    "health_reminders_desc": {"ar": "تذكير بمواعيد التحاليل الدورية والفحوصات", "en": "Reminder for periodic tests and checkup appointments"},
    "medication_reminders": {"ar": "تذكيرات الأدوية", "en": "Medication Reminders"},
    "medication_reminders_desc": {"ar": "إشعار بمواعيد تناول الأدوية", "en": "Notification for medication intake schedules"},
    "family_notifications": {"ar": "إشعارات العائلة", "en": "Family Notifications"},
    "family_updates": {"ar": "تحديثات العائلة", "en": "Family Updates"},
    "family_updates_desc": {"ar": "تنبيه عند إضافة تحليل جديد لأحد أفراد العائلة", "en": "Alert when a new test is added for a family member"},
    "app_updates": {"ar": "تحديثات التطبيق", "en": "App Updates"},
    "news_and_offers": {"ar": "الأخبار والعروض", "en": "News and Offers"},
    "news_and_offers_desc": {"ar": "جديد التطبيق والنصائح الطبية والعروض", "en": "New app features, medical tips, and offers"},
    
    # home_screen.dart / home_detail_screen.dart
    "current_medications": {"ar": "الأدوية الحالية", "en": "Current Medications"},
    "see_all": {"ar": "عرض الكل", "en": "See All"},
    "taken": {"ar": "تم أخذها", "en": "Taken"},
    "health_tips": {"ar": "نصائح صحية", "en": "Health Tips"},
    "daily_water": {"ar": "شرب الماء يومياً", "en": "Daily Water Intake"},
    "drink_8_cups": {"ar": "احرص على شرب 8 أكواب من الماء", "en": "Make sure to drink 8 cups of water"},
    "health_articles": {"ar": "مقالات صحية لك", "en": "Health Articles for You"},
    "vitamin_d_importance": {"ar": "أهمية فيتامين د", "en": "Importance of Vitamin D"},
    "read_more": {"ar": "اقرأ المزيد عن فوائد ومصادر فيتامين د", "en": "Read more about the benefits and sources of Vitamin D"},
    "healthy_diet": {"ar": "الغذاء الصحي المتوازن", "en": "Healthy Balanced Diet"},
    "healthy_diet_desc": {"ar": "كيفية بناء نظام غذائي صحي ومتكامل", "en": "How to build a healthy and complete diet"},
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

print("Translations added!")
