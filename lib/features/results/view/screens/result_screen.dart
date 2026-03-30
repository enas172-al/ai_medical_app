import 'package:flutter/material.dart';
import '../widgets/expandable_result_item.dart';
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              /// 🔹 العنوان
              const Text(
                "نتائج التحاليل",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "20 مارس 2026",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              /// 🔹 الأزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: const Text("مشاركة"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.save),
                      label: const Text("حفظ"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔥 الكروت
              ExpandableCard(
                title: "سكر الدم",
                value: "95",
                unit: "mg/dL",
                status: "طبيعي",
              ),

              ExpandableCard(
                title: "الهيموجلوبين",
                value: "15.2",
                unit: "g/dL",
                status: "طبيعي",
              ),

              ExpandableCard(
                title: "الكوليسترول الكلي",
                value: "220",
                unit: "mg/dL",
                status: "مرتفع",
              ),

              ExpandableCard(
                title: "فيتامين د",
                value: "18",
                unit: "ng/mL",
                status: "منخفض",
              ),

              const SizedBox(height: 20),

              /// 🔹 ملاحظة
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "ملاحظة: هذه النتائج تم تحليلها بواسطة الذكاء الاصطناعي. يرجى استشارة الطبيب.",
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

