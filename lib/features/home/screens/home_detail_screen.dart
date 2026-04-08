import 'package:flutter/material.dart';
import '../../results/view/widgets/expandable_result_item.dart';

class HomeDetailScreen extends StatelessWidget {
  const HomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 10),
              
              // 🔝 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/logo.png', width: 40, height: 40),
                      const SizedBox(width: 8),
                      const Text(
                        "labby",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 🧾 Title
              const Text(
                "نتائج التحاليل",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "20 مارس 2026",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // حفظ Button (Right in RTL)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bookmark_border, size: 20, color: Colors.black87),
                          SizedBox(width: 8),
                          Text(
                            "حفظ",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // مشاركة Button (Left in RTL)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.share_outlined, size: 20, color: Colors.black87),
                          SizedBox(width: 8),
                          Text(
                            "مشاركة",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Glucose
              const ExpandableCard(
                title: "السكر الصائم",
                subtitle: "Fasting Sugar",
                value: "95",
                unit: "mg/dL",
                status: "طبيعي",
                normalRange: "mg/dL 70-100",
                interpretation: "مستوى السكر في الدم ضمن المعدل الطبيعي، مما يشير إلى صحة جيدة لعملية التمثيل الغذائي للجلوكوز.",
                recommendation: "حافظ على نمط حياة صحي مع نظام غذائي متوازن وممارسة الرياضة بانتظام.",
              ),

              // Hemoglobin
              const ExpandableCard(
                title: "الهيموجلوبين",
                subtitle: "Hemoglobin",
                value: "15.2",
                unit: "g/dL",
                status: "طبيعي",
                normalRange: "g/dL 13.5-17.5",
                interpretation: "مستوى الهيموجلوبين طبيعي، مما يعني أن قدرة الدم على نقل الأكسجين جيدة.",
                recommendation: "استمر في تناول الأطعمة الغنية بالحديد مثل اللحوم الحمراء والخضروات الورقية.",
              ),

              // Cholesterol
              const ExpandableCard(
                title: "الكوليسترول",
                subtitle: "Cholesterol",
                value: "220",
                unit: "mg/dL",
                status: "مرتفع",
                normalRange: "mg/dL 200 >",
                interpretation: "مستوى الكوليسترول أعلى قليلاً من الطبيعي، مما قد يزيد من خطر الإصابة بأمراض القلب والأوعية الدموية.",
                recommendation: "يُنصح بتقليل تناول الدهون المشبعة، وزيادة النشاط البدني، واستشارة الطبيب لمتابعة الحالة.",
              ),

              // Vitamin D
              const ExpandableCard(
                title: "فيتامين د",
                subtitle: "Vitamin D",
                value: "18",
                unit: "ng/mL",
                status: "منخفض",
                normalRange: "ng/mL 30-100",
                interpretation: "مستوى فيتامين د منخفض، مما قد يؤثر على صحة العظام والجهاز المناعي.",
                recommendation: "يُنصح بالتعرض لأشعة الشمس لمدة 15-20 دقيقة يومياً، وتناول مكملات فيتامين د بعد استشارة الطبيب.",
              ),

              // White Blood Cells
              const ExpandableCard(
                title: "خلايا الدم البيضاء",
                subtitle: "White Blood Cells",
                value: "7.5",
                unit: "μL/10³x",
                status: "طبيعي",
                normalRange: "μL/10³x 4.5-11.0",
                interpretation: "عدد خلايا الدم البيضاء طبيعي، مما يشير إلى صحة الجهاز المناعي.",
                recommendation: "حافظ على نمط حياة صحي لدعم الجهاز المناعي.",
              ),

              // Blood Pressure
              const ExpandableCard(
                title: "ضغط الدم",
                subtitle: "Blood Pressure",
                value: "120/80",
                unit: "mmHg",
                status: "طبيعي",
                normalRange: "mmHg 120/80 >",
                interpretation: "ضغط الدم في النطاق الصحي والمثالي.",
                recommendation: "استمر في ممارسة الرياضة والتقليل من الصوديوم في الطعام.",
              ),

              const SizedBox(height: 10),

              // Blue Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "ملاحظة: هذه النتائج تم تحليلها بواسطة الذكاء الاصطناعي. يُرجى استشارة الطبيب المختص للحصول على تقييم دقيق ومتابعة طبية.",
                  style: TextStyle(
                    color: Color(0xFF4B8DCF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
