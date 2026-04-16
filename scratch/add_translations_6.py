import json

ar_path = 'c:/src/ai_medical_app/assets/translations/ar.json'
en_path = 'c:/src/ai_medical_app/assets/translations/en.json'

with open(ar_path, 'r', encoding='utf-8') as f:
    ar_data = json.load(f)

with open(en_path, 'r', encoding='utf-8') as f:
    en_data = json.load(f)

new_translations = {
    "account_protected": {"ar": "حسابك محمي", "en": "Your account is protected"},
    "data_security_guarantee": {"ar": "جميع بياناتك مشفرة ومحمية بأعلى معايير الأمان", "en": "All your data is encrypted and protected by the highest security standards"},
    "auth_and_security": {"ar": "المصادقة والأمان", "en": "Authentication & Security"},
    "biometric_auth": {"ar": "المصادقة البيومترية", "en": "Biometric Authentication"},
    "biometric_desc": {"ar": "بصمة الإصبع أو التعرف على الوجه", "en": "Fingerprint or Face Recognition"},
    "two_factor_auth": {"ar": "المصادقة الثنائية", "en": "Two-Factor Authentication"},
    "two_factor_desc": {"ar": "حماية إضافية عند تسجيل الدخول", "en": "Extra protection during login"},
    "auto_lock": {"ar": "القفل التلقائي", "en": "Auto-Lock"},
    "auto_lock_desc": {"ar": "قفل التطبيق عند عدم الاستخدام", "en": "Lock the app when not in use"},
    "change_password": {"ar": "تغيير كلمة المرور", "en": "Change Password"},
    "change_password_desc": {"ar": "تحديث كلمة المرور الخاصة بك", "en": "Update your password"},
    "privacy_settings": {"ar": "إعدادات الخصوصية", "en": "Privacy Settings"},
    "data_encryption_toggle": {"ar": "تشفير البيانات", "en": "Data Encryption"},
    "data_encryption_desc": {"ar": "تشفير جميع البيانات الطبية", "en": "Encrypt all medical data"},
    "family_share": {"ar": "مشاركة مع العائلة", "en": "Family Share"},
    "family_share_desc": {"ar": "السماح للعائلة بعرض بياناتك", "en": "Allow family to view your data"},
    "analytics_data": {"ar": "بيانات التحليلات", "en": "Analytics Data"},
    "analytics_data_desc": {"ar": "مشاركة بيانات مجهولة لتحسين الخدمة", "en": "Share anonymous data to improve service"},
    "download_my_data": {"ar": "تحميل بياناتي", "en": "Download My Data"},
    "download_my_data_desc": {"ar": "تصدير نسخة من جميع بياناتك", "en": "Export a copy of all your data"},
    "delete_my_account": {"ar": "حذف حسابي", "en": "Delete My Account"},
    "delete_my_account_desc": {"ar": "حذف حسابك وجميع بياناتك نهائياً", "en": "Permanently delete your account and all data"},
    "security_tips": {"ar": "نصائح الأمان", "en": "Security Tips"},
    "tip_strong_password": {"ar": "استخدم كلمة مرور قوية ومعقدة", "en": "Use a strong and complex password"},
    "tip_dont_share": {"ar": "لا تشارك معلومات حسابك مع أحد", "en": "Do not share your account information with anyone"},
    "tip_enable_2fa": {"ar": "فعّل المصادقة الثنائية لحماية إضافية", "en": "Enable Two-Factor Authentication for extra protection"},
    "tip_review_activity": {"ar": "راجع نشاط حسابك بانتظام", "en": "Review your account activity regularly"},
    "current_password": {"ar": "كلمة المرور الحالية", "en": "Current Password"},
    "new_password": {"ar": "كلمة المرور الجديدة", "en": "New Password"},
    "confirm_password": {"ar": "تأكيد كلمة المرور", "en": "Confirm Password"},
    "save_password": {"ar": "حفظ كلمة المرور", "en": "Save Password"},
    "important_warning": {"ar": "تحذير هام", "en": "Important Warning"},
    "delete_warning_1": {"ar": "سيتم حذف جميع بياناتك الطبية نهائياً", "en": "All your medical data will be permanently deleted"},
    "delete_warning_2": {"ar": "لن تتمكن من استرجاع حسابك أو بياناتك", "en": "You will not be able to recover your account or data"},
    "delete_warning_3": {"ar": "سيتم إلغاء جميع الاشتراكات المرتبطة", "en": "All associated subscriptions will be cancelled"},
    "delete_warning_4": {"ar": "هذا الإجراء لا يمكن التراجع عنه", "en": "This action cannot be undone"},
    "delete_confirmation_text": {"ar": "للتأكيد، اكتب: ", "en": "To confirm, type: "},
    "delete_confirm_phrase": {"ar": "حذف حسابي", "en": "delete my account"},
    "cancel": {"ar": "إلغاء", "en": "Cancel"},
    "delete_account_permanently": {"ar": "حذف الحساب نهائياً", "en": "Delete Account Permanently"},
    "download_data_process_desc": {"ar": "سيتم تجميع كافة بياناتك (الالتقارير الطبية، التحاليل، والإعدادات) في ملف آمن وتجهيزها للتنزيل. قد تستغرق هذه العملية بضع دقائق.", "en": "All your data (medical reports, analyses, and settings) will be compiled into a secure file and prepared for download. This process may take a few minutes."},
    "extract_copy": {"ar": "استخراج النسخة", "en": "Extract Copy"},
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

print("Translations added for security screen!")
