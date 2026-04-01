import 'package:flutter/material.dart';
import 'user_guide_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "المساعدة والدعم",
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
              // 🌐 Banner
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
                    Icon(Icons.help_outline, color: Colors.white, size: 56),
                    SizedBox(height: 12),
                    Text(
                      "كيف يمكننا مساعدتك؟",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "نحن هنا لدعمك في أي وقت",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔍 Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "...ابحث عن موضوع مساعدة",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 📞 Contact Us
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "تواصل معنا",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactRow("الدردشة المباشرة", "متاح من 9 صباحاً إلى 9 مساءً", Icons.chat_bubble_outline, const Color(0xFF1FB6A6)),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    _buildContactRow("البريد الإلكتروني", "support@labby.app", Icons.email_outlined, Colors.blueAccent),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    _buildContactRow("الاتصال الهاتفي", "+966 50 123 4567", Icons.call_outlined, Colors.purpleAccent),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ❓ FAQ Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "الأسئلة الشائعة",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    FAQItem(
                      question: "كيف أقوم بتصوير التحاليل الطبية؟",
                      answer: "اضغط على أيقونة الكاميرا في الصفحة الرئيسية، ثم قم بتصوير التحليل بوضوح. سيقوم التطبيق بتحليل النتائج تلقائياً وعرضها لك مع التفسيرات.",
                    ),
                    FAQItem(
                      question: "هل بياناتي الطبية آمنة؟",
                      answer: "نعم، جميع بياناتك مشفرة بأعلى معايير الأمان ولا يتم مشاركتها مع أي طرف ثالث. نحن نلتزم بمعايير خصوصية البيانات الصحية HIPAA.",
                    ),
                    FAQItem(
                      question: "كيف أربط حساب أحد أفراد عائلتي؟",
                      answer: "من صفحة الملف الشخصي، انقر على 'نظام العائلة' ثم 'ربط حساب عائلي'. شارك الكود مع أفراد عائلتك ليتمكنوا من الربط بحسابك.",
                    ),
                    FAQItem(
                      question: "هل يمكنني تصدير نتائج تحاليلي؟",
                      answer: "نعم، يمكنك تصدير جميع نتائجك بصيغة PDF. من صفحة السجل، اضغط على أيقونة التصدير في أعلى الصفحة.",
                    ),
                    FAQItem(
                      question: "كيف أضيف تذكير للأدوية؟",
                      answer: "من قسم الأدوية في الشريط السفلي، اضغط على زر إضافة دواء جديد. أدخل تفاصيل الدواء والمواعيد، وسيقوم التطبيق بتذكيرك تلقائياً.",
                    ),
                    FAQItem(
                      question: "ما هي دقة تحليل النتائج؟",
                      answer: "نستخدم تقنية الذكاء الاصطناعي المتقدمة بدقة تصل إلى 95%. ومع ذلك، يجب استشارة الطبيب دائماً للحصول على التشخيص النهائي.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔗 Useful Links
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "الدعم والمعلومات",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLinkRow(
                      context,
                      "دليل المستخدم",
                      Icons.article_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserGuideScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    _buildLinkRow(
                      context, 
                      "سياسة الخصوصية", 
                      Icons.article_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    _buildLinkRow(
                      context, 
                      "شروط الاستخدام", 
                      Icons.article_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsOfUseScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 📱 App Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1FB6A6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text("❤️", style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Labby",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "الإصدار 1.0.0",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "جميع الحقوق محفوظة Labby 2026 ©",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🚨 Emergency Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text("🚨", style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Text(
                          "حالة طوارئ طبية؟",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "هذا التطبيق لا يغني عن استشارة الطبيب. في حالة الطوارئ، اتصل فوراً بالإسعاف أو توجه لأقرب مستشفى.",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Text("📞", style: TextStyle(fontSize: 16)),
                        label: const Text(
                          "اتصل بالإسعاف 997",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildContactRow(String title, String subtitle, IconData icon, Color iconColor) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
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

  Widget _buildLinkRow(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1FB6A6), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}

class FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const FAQItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF1FB6A6) : Colors.grey.shade200,
          width: isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              isExpanded = expanded;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: Text(
            widget.question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          iconColor: Colors.grey,
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(
              widget.answer,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
