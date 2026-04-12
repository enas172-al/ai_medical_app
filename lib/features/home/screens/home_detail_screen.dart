import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import '../../results/view/widgets/expandable_result_item.dart';

class HomeDetailScreen extends StatelessWidget {
  const HomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
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
                      Text(
                        "app_title".tr(),
                        style: const TextStyle(
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
              Text(
                "analysis_results".tr(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "example_dob".tr(),
                style: const TextStyle(
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
                        children: [
                          const Icon(Icons.bookmark_border, size: 20, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            "save_btn".tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
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
                        children: [
                          const Icon(Icons.share_outlined, size: 20, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text(
                            "share_btn".tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Glucose
              ExpandableCard(
                title: "fasting_sugar".tr(),
                subtitle: "Fasting Sugar",
                value: "95",
                unit: "mg/dL",
                status: "normal_status".tr(),
                normalRange: "mg/dL 70-100",
                interpretation: "fasting_sugar_interp".tr(),
                recommendation: "balanced_diet_advice".tr(),
              ),

              // Hemoglobin
              ExpandableCard(
                title: "hemoglobin".tr(),
                subtitle: "Hemoglobin",
                value: "15.2",
                unit: "g/dL",
                status: "normal_status".tr(),
                normalRange: "g/dL 13.5-17.5",
                interpretation: "hemoglobin_interp".tr(),
                recommendation: "iron_foods_advice".tr(),
              ),

              // Cholesterol
              ExpandableCard(
                title: "cholesterol".tr(),
                subtitle: "Cholesterol",
                value: "220",
                unit: "mg/dL",
                status: "high_status".tr(),
                normalRange: "mg/dL 200 >",
                interpretation: "cholesterol_interp".tr(),
                recommendation: "reduce_fat_advice".tr(),
              ),

              // Vitamin D
              ExpandableCard(
                title: "vitamin_d".tr(),
                subtitle: "Vitamin D",
                value: "18",
                unit: "ng/mL",
                status: "low_status".tr(),
                normalRange: "ng/mL 30-100",
                interpretation: "vitamin_d_interp".tr(),
                recommendation: "sun_exposure_advice".tr(),
              ),

              // White Blood Cells
              ExpandableCard(
                title: "wbc".tr(),
                subtitle: "White Blood Cells",
                value: "7.5",
                unit: "μL/10³x",
                status: "normal_status".tr(),
                normalRange: "μL/10³x 4.5-11.0",
                interpretation: "wbc_interp".tr(),
                recommendation: "immune_system_good_advice".tr(),
              ),

              // Blood Pressure
              ExpandableCard(
                title: "blood_pressure".tr(),
                subtitle: "Blood Pressure",
                value: "120/80",
                unit: "mmHg",
                status: "normal_status".tr(),
                normalRange: "mmHg 120/80 >",
                interpretation: "bp_interp".tr(),
                recommendation: "exercise_stress_advice".tr(),
              ),

              const SizedBox(height: 10),

              // Blue Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "ai_analysis_note".tr(),
                  style: const TextStyle(
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
