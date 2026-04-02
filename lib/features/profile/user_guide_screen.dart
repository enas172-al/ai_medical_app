import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "دليل المستخدم",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Directionality(
          textDirection: TextDirection.rtl,
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 📱 Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1FB6A6), Color(0xFF17A2A2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(Icons.phone_iphone, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "كيف تستخدم التطبيق؟",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A4582),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "اتبع هذه الخطوات البسيطة للاستفادة من جميع ميزات التطبيق",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Step Cards
              _buildStepCard(
                icon: Icons.camera_alt_outlined,
                iconColor: const Color(0xFF1FB6A6),
                title: "تصوير التحليل",
                bullets: [
                  "اضغط على زر تصوير تحليل",
                  "ضع التقرير داخل الإطار",
                  "اضغط تحليل",
                ],
              ),
              _buildStepCard(
                icon: Icons.bar_chart_outlined,
                iconColor: const Color(0xFF29B6F6),
                title: "عرض النتائج",
                bullets: [
                  "يتم عرض القيم مع الحالة (مرتفع / طبيعي / منخفض)",
                ],
              ),
              _buildStepCard(
                icon: Icons.calendar_today_outlined,
                iconColor: Colors.blueAccent,
                title: "متابعة التاريخ",
                bullets: [
                  "يمكنك متابعة تحاليلك السابقة",
                  "عرضها في شكل رسوم بيانية",
                ],
              ),
              _buildStepCard(
                icon: Icons.medication_outlined,
                iconColor: Colors.purpleAccent,
                title: "إدارة الأدوية",
                bullets: [
                  "إضافة أدوية",
                  "تحديد مواعيد التذكير",
                ],
              ),
              _buildStepCard(
                icon: Icons.group_outlined,
                iconColor: Colors.pinkAccent,
                title: "ربط حساب عائلي",
                bullets: [
                  "يمكنك ربط حساب أحد أفراد العائلة",
                  "متابعة نتائجه الصحية",
                ],
              ),

              // 💡 Important Tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1FB6A6), Color(0xFF17A2A2)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1FB6A6).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "نصيحة مهمة",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "للحصول على أفضل النتائج، تأكد من وضوح صورة التحليل والإضاءة الجيدة عند التصوير. استخدم خلفية بلون موحد لتسهيل عملية التحليل.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.6,
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

  Widget _buildStepCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> bullets,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...bullets.map((bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF1FB6A6), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
