import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../results/view/widgets/expandable_result_item.dart';

class HomeDetailScreen extends StatelessWidget {
  const HomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              // share and save buttons at the top
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.share_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "مشاركة",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bookmark_border, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "حفظ",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Glucose
              const ExpandableCard(
                title: "سكر الدم",
                subtitle: "Glucose",
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
                title: "الكوليسترول الكلي",
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
