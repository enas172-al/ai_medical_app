import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = [
      {
        "name": "fasting_sugar".tr(),
        "value": "95",
        "unit": "mg/dL",
        "status": "normal",
        "icon": Icons.bolt,
        "interpretation": "fasting_sugar_interp".tr(),
        "advice": "balanced_diet_advice".tr()
      },
      {
        "name": "hemoglobin".tr(),
        "value": "15.2",
        "unit": "g/dL",
        "status": "normal",
        "icon": Icons.water_drop_outlined,
        "interpretation": "hemoglobin_interp".tr(),
        "advice": "iron_foods_advice".tr()
      },
      {
        "name": "cholesterol".tr(),
        "value": "220",
        "unit": "mg/dL",
        "status": "high",
        "icon": Icons.warning_amber_rounded,
        "interpretation": "cholesterol_interp".tr(),
        "advice": "reduce_fat_advice".tr()
      },
      {
        "name": "vitamin_d".tr(),
        "value": "18",
        "unit": "ng/mL",
        "status": "low",
        "icon": Icons.wb_sunny_outlined,
        "interpretation": "vitamin_d_interp".tr(),
        "advice": "sun_exposure_advice".tr()
      },
      {
        "name": "wbc".tr(),
        "value": "7.5",
        "unit": "x10^9/L",
        "status": "normal",
        "icon": Icons.biotech_outlined,
        "interpretation": "wbc_interp".tr(),
        "advice": "immune_system_good_advice".tr()
      },
      {
        "name": "blood_pressure".tr(),
        "value": "120/80",
        "unit": "mmHg",
        "status": "normal",
        "icon": Icons.water_drop_outlined,
        "interpretation": "bp_interp".tr(),
        "advice": "exercise_stress_advice".tr()
      }
    ];

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ///  Back + Branding
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        Text(
                          "labby",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),

                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                ///  Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        "analysis_results".tr(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// 🔘 Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton("save_btn".tr(), Icons.save_alt_outlined),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildActionButton("share_btn".tr(), Icons.share_outlined),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// النتائج
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return _buildItem(
                        context: context,
                        title: item["name"] as String,
                        value: item["value"] as String,
                        unit: item["unit"] as String,
                        statusKey: item["status"] as String,
                        icon: item["icon"] as IconData,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                /// ملاحظة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FB6A6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "ai_analysis_note".tr(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Color(0xFF1FB6A6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1F2937)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "high":
        return const Color(0xFFF5222D);
      case "low":
        return const Color(0xFFFAAD14);
      default:
        return const Color(0xFF52C41A);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case "high":
        return const Color(0xFFFFF1F0);
      case "low":
        return const Color(0xFFFFF7E6);
      default:
        return const Color(0xFFF6FFED);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case "high":
        return "high_status".tr();
      case "low":
        return "low_status".tr();
      default:
        return "normal_status".tr();
    }
  }

  Widget _buildItem({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required String statusKey,
    required IconData icon,
  }) {
    final statusColor = _getStatusColor(statusKey);
    final statusBg = _getStatusBg(statusKey);
    final statusText = _getStatusText(statusKey);

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  unit,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  title == "fasting_sugar".tr() ? "Glucose" : 
                  title == "hemoglobin".tr() ? "Hemoglobin" :
                  title == "cholesterol".tr() ? "Cholesterol" :
                  title == "vitamin_d".tr() ? "Vitamin D" : 
                  title == "blood_pressure".tr() ? "Blood Pressure" : "White Blood Cells",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}