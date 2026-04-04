import 'package:flutter/material.dart';

class ScanResultsScreen extends StatelessWidget {
  const ScanResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> results = [
      {
        "id": "1",
        "name": "سكر الدم",
        "subName": "Glucose",
        "value": "95",
        "unit": "mg/dL",
        "range": "70-100",
        "status": "طبيعي",
        "statusColor": Colors.green,
        "interpretation": "مستوى السكر في الدم ضمن المعدل الطبيعي، مما يشير إلى صحة جيدة لعملية التمثيل الغذائي للجلوكوز.",
        "advice": "حافظ على نمط حياة صحي مع نظام غذائي متوازن وممارسة الرياضة بانتظام."
      },
      {
        "id": "2",
        "name": "الهيموجلوبين",
        "subName": "Hemoglobin",
        "value": "15.2",
        "unit": "g/dL",
        "range": "13.5-17.5",
        "status": "طبيعي",
        "statusColor": Colors.green,
        "interpretation": "مستوى الهيموجلوبين طبيعي، مما يعني أن قدرة الدم على نقل الأكسجين جيدة.",
        "advice": "استمر في تناول الأطعمة الغنية بالحديد مثل اللحوم الحمراء والخضروات الورقية."
      },
      {
        "id": "3",
        "name": "الكوليسترول الكلي",
        "subName": "Cholesterol",
        "value": "220",
        "unit": "mg/dL",
        "range": "< 200",
        "status": "مرتفع",
        "statusColor": Colors.red,
        "interpretation": "مستوى الكوليسترول أعلى قليلاً من الطبيعي، مما قد يزيد من خطر الإصابة بأمراض القلب والأوعية الدموية.",
        "advice": "يُنصح بتقليل تناول الدهون المشبعة، وزيادة النشاط البدني، واستشارة الطبيب لمتابعة الحالة."
      },
      {
        "id": "4",
        "name": "فيتامين د",
        "subName": "Vitamin D",
        "value": "18",
        "unit": "ng/mL",
        "range": "30-100",
        "status": "منخفض",
        "statusColor": Colors.orange,
        "interpretation": "مستوى فيتامين د منخفض، مما قد يؤثر على صحة العظام والجهاز المناعي.",
        "advice": "يُنصح بالتعرض لأشعة الشمس لمدة 15-20 دقيقة يومياً، وتناول مكملات فيتامين د بعد استشارة الطبيب."
      },
      {
        "id": "5",
        "name": "خلايا الدم البيضاء",
        "subName": "White Blood Cells",
        "value": "7.5",
        "unit": "µL/10³",
        "range": "4.5-11.0",
        "status": "طبيعي",
        "statusColor": Colors.green,
        "interpretation": "تعداد خلايا الدم البيضاء ضمن النطاق الطبيعي، مما يشير إلى وظيفة مناعية جيدة.",
        "advice": "استمر في اتباع العادات الصحية لتعزيز جهازك المناعي."
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "نتائج التحاليل",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF1FB6A6).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.science_outlined, color: Color(0xFF1FB6A6), size: 20),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: const [
                     Text(
                      "labby | لابي",
                      style: TextStyle(color: Color(0xFF1FB6A6), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "20 مارس 2026",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(Icons.share_outlined, "مشاركة", Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(Icons.save_outlined, "حفظ", Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1FB6A6).withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 3, child: Text("اسم التحليل", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("القيمة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("الوحدة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("المعدل الطبيعي", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    SizedBox(width: 30),
                  ],
                ),
              ),

              // Table Body
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final res = results[index];
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(res["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(res["subName"], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Expanded(flex: 2, child: Text(res["value"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Expanded(flex: 2, child: Text(res["unit"], style: const TextStyle(fontSize: 12, color: Colors.grey))),
                        Expanded(flex: 2, child: Text(res["range"], style: const TextStyle(fontSize: 11, color: Colors.grey))),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: res["statusColor"].withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(
                            res["status"] == "طبيعي" ? Icons.check : (res["status"] == "مرتفع" ? Icons.trending_up : Icons.trending_down),
                            color: res["statusColor"],
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Interpretations Section
              Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1FB6A6), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "التفسيرات والنصائح",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ...results.map((res) => _buildDetailCard(res)).toList(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDetailCard(Map<String, dynamic> res) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1FB6A6).withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: res["statusColor"].withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                       Icon(res["status"] == "طبيعي" ? Icons.check_circle_outline : Icons.error_outline, color: res["statusColor"], size: 14),
                       const SizedBox(width: 4),
                       Text(res["status"], style: TextStyle(color: res["statusColor"], fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(res["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(res["subName"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFF1FB6A6), shape: BoxShape.circle),
                  child: Center(child: Text(res["id"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
          
          // Metrics Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildMetricItem("المعدل الطبيعي", "${res["unit"]} ${res["range"]}")),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricItem("القيمة المقاسة", "${res["unit"]} ${res["value"]}")),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Medical Interpretation
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.circle, color: Colors.blue, size: 8),
                    SizedBox(width: 8),
                    Text("التفسير الطبي", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(res["interpretation"], style: TextStyle(color: Colors.blue.shade900, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Advice Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FFED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text("النصائح والتوصيات", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(res["advice"], style: TextStyle(color: Colors.green.shade900, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
