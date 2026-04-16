import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import '../../results/view/widgets/expandable_result_item.dart';
import '../../../core/models/analysis_model.dart';
import '../../../core/services/database_service.dart';

class HomeDetailScreen extends StatelessWidget {
  const HomeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

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
                user?.email ?? "example_dob".tr(),
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

              if (userId == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "history_sign_in".tr(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              else
                StreamBuilder<List<AnalysisModel>>(
                  stream: DatabaseService().getAnalyses(userId),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "${"no_data_found".tr()} (${snap.error})",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final list = snap.data ?? const <AnalysisModel>[];
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "history_empty".tr(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final a in list)
                          ExpandableCard(
                            title: a.testName,
                            subtitle: a.testName,
                            value: a.value.toString(),
                            unit: a.unit,
                            status: _localizedStatus(a.status),
                            normalRange: _normalRangeText(a),
                            interpretation: a.simplifiedExplanation?.trim().isNotEmpty == true
                                ? a.simplifiedExplanation!.trim()
                                : "ai_analysis_note".tr(),
                            recommendation: "medical_review_needed_rule".tr(),
                          ),
                      ],
                    );
                  },
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

  static String _localizedStatus(String raw) {
    final s = raw.trim().toLowerCase();
    if (s == 'high') return "high_status".tr();
    if (s == 'low') return "low_status".tr();
    return "normal_status".tr();
  }

  static String _normalRangeText(AnalysisModel a) {
    final min = a.normalRange['min'];
    final max = a.normalRange['max'];
    final unit = a.unit.trim();
    if (min == null && max == null) return unit.isEmpty ? '-' : unit;
    final range = (min != null && max != null)
        ? "${min.toString()}-${max.toString()}"
        : (min != null)
            ? ">= ${min.toString()}"
            : "<= ${max.toString()}";
    return unit.isEmpty ? range : "$unit $range";
  }
}
