import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // Authentication toggles
  bool biometricAuth = true;
  bool twoFactorAuth = false;
  bool autoLock = true;

  // Privacy toggles
  bool dataEncryption = true;
  bool familyShare = true;
  bool analyticsData = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "الخصوصية والأمان",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Directionality(
          textDirection: TextDirection.ltr,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛡️ Top Secured Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1FB6A6), Color(0xFF17A2A2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1FB6A6).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: const [
                    Icon(Icons.security_outlined, color: Colors.white, size: 52),
                    SizedBox(height: 12),
                    Text(
                      "حسابك محمي",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "جميع بياناتك مشفرة ومحمية بأعلى معايير الأمان",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔒 Authentication & Security Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lock_outline, color: Color(0xFF1FB6A6)),
                        SizedBox(width: 8),
                        Text(
                          "المصادقة والأمان",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildIconToggleRow(
                      title: "المصادقة البيومترية",
                      subtitle: "بصمة الإصبع أو التعرف على الوجه",
                      icon: Icons.fingerprint,
                      iconColor: const Color(0xFF1FB6A6),
                      value: biometricAuth,
                      onChanged: (val) => setState(() => biometricAuth = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildIconToggleRow(
                      title: "المصادقة الثنائية",
                      subtitle: "حماية إضافية عند تسجيل الدخول",
                      icon: Icons.phone_iphone_outlined,
                      iconColor: Colors.purple.shade300,
                      value: twoFactorAuth,
                      onChanged: (val) => setState(() => twoFactorAuth = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildIconToggleRow(
                      title: "القفل التلقائي",
                      subtitle: "قفل التطبيق عند عدم الاستخدام",
                      icon: Icons.lock_outline,
                      iconColor: Colors.blueAccent,
                      value: autoLock,
                      onChanged: (val) => setState(() => autoLock = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildArrowActionRow(
                      title: "تغيير كلمة المرور",
                      subtitle: "تحديث كلمة المرور الخاصة بك",
                      icon: Icons.key_outlined,
                      iconColor: Colors.orange.shade400,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 👁️ Privacy Settings Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.remove_red_eye_outlined, color: Color(0xFF1FB6A6)),
                        SizedBox(width: 8),
                        Text(
                          "إعدادات الخصوصية",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextToggleRow(
                      title: "تشفير البيانات",
                      subtitle: "تشفير جميع البيانات الطبية",
                      value: dataEncryption,
                      onChanged: (val) => setState(() => dataEncryption = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextToggleRow(
                      title: "مشاركة مع العائلة",
                      subtitle: "السماح للعائلة بعرض بياناتك",
                      value: familyShare,
                      onChanged: (val) => setState(() => familyShare = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextToggleRow(
                      title: "بيانات التحليلات",
                      subtitle: "مشاركة بيانات مجهولة لتحسين الخدمة",
                      value: analyticsData,
                      onChanged: (val) => setState(() => analyticsData = val),
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextArrowRow(
                      title: "تحميل بياناتي",
                      subtitle: "تصدير نسخة من جميع بياناتك",
                      onTap: () {},
                    ),
                    const Divider(height: 30, color: Color(0xFFEEEEEE)),
                    _buildTextArrowRow(
                      title: "حذف حسابي",
                      subtitle: "حذف حسابك وجميع بياناتك نهائياً",
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 💡 Security Tips Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9E7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFBE4A0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lock, color: Color(0xFFD4A017), size: 24),
                        SizedBox(width: 8),
                        Text(
                          "نصائح الأمان",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B4D00),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTipRow("استخدم كلمة مرور قوية ومعقدة"),
                    const SizedBox(height: 10),
                    _buildTipRow("لا تشارك معلومات حسابك مع أحد"),
                    const SizedBox(height: 10),
                    _buildTipRow("فعّل المصادقة الثنائية لحماية إضافية"),
                    const SizedBox(height: 10),
                    _buildTipRow("راجع نشاط حسابك بانتظام"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Color(0xFFD4A017)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B4D00),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconToggleRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.black87,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildArrowActionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }

  Widget _buildTextToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.black87,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildTextArrowRow({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDestructive ? Colors.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}
