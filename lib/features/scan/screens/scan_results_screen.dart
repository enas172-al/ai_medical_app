import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui' as ui;

class ScanResultsScreen extends StatelessWidget {
  const ScanResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> results = [
      {
        "id": "1",
        "name": "fasting_sugar".tr(),
        "subName": "glucose_sub".tr(),
        "value": "95",
        "unit": "mg/dL",
        "range": "70-100",
        "status": "normal_status".tr(),
        "statusColor": Colors.green,
        "interpretation": "glucose_interpretation".tr(),
        "advice": "glucose_advice".tr()
      },
      {
        "id": "2",
        "name": "hemoglobin".tr(),
        "subName": "hemoglobin_sub".tr(),
        "value": "15.2",
        "unit": "g/dL",
        "range": "13.5-17.5",
        "status": "normal_status".tr(),
        "statusColor": Colors.green,
        "interpretation": "hemoglobin_interpretation".tr(),
        "advice": "hemoglobin_advice".tr()
      },
      {
        "id": "3",
        "name": "cholesterol".tr(),
        "subName": "cholesterol_sub".tr(),
        "value": "220",
        "unit": "mg/dL",
        "range": "< 200",
        "status": "high_status".tr(),
        "statusColor": Colors.red,
        "interpretation": "cholesterol_interpretation".tr(),
        "advice": "cholesterol_advice".tr()
      },
      {
        "id": "4",
        "name": "vitamin_d".tr(),
        "subName": "vitamin_d_sub".tr(),
        "value": "18",
        "unit": "ng/mL",
        "range": "30-100",
        "status": "low_status".tr(),
        "statusColor": Colors.orange,
        "interpretation": "vitamin_d_interpretation".tr(),
        "advice": "vitamin_d_advice".tr()
      },
      {
        "id": "5",
        "name": "wbc".tr(),
        "subName": "wbc_sub".tr(),
        "value": "7.5",
        "unit": "µL/10³",
        "range": "4.5-11.0",
        "status": "normal_status".tr(),
        "statusColor": Colors.green,
        "interpretation": "wbc_interpretation".tr(),
        "advice": "wbc_advice".tr()
      },
    ];

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "scan_results_title".tr(),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset('assets/images/logo.png', width: 48, height: 48),
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
                  children: [
                    Text(
                      "labby_title".tr(),
                      style: const TextStyle(color: Color(0xFF1FB6A6), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "example_dob".tr(),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(Icons.share_outlined, "share".tr(), Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(Icons.save_outlined, "save".tr(), Colors.black87),
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
                  children: [
                    Expanded(flex: 3, child: Text("test_name_col".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("value_col".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("unit_col".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Expanded(flex: 2, child: Text("normal_range_col".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    const SizedBox(width: 30),
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
                            res["status"] == "normal_status".tr() ? Icons.check : (res["status"] == "high_status".tr() ? Icons.trending_up : Icons.trending_down),
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
                  Text(
                    "interpretations_and_advice".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                       Icon(res["status"] == "normal_status".tr() ? Icons.check_circle_outline : Icons.error_outline, color: res["statusColor"], size: 14),
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
                Expanded(child: _buildMetricItem("normal_range_label".tr(), "${res["unit"]} ${res["range"]}")),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricItem("measured_value_label".tr(), "${res["unit"]} ${res["value"]}")),
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
                  children: [
                    const Icon(Icons.circle, color: Colors.blue, size: 8),
                    const SizedBox(width: 8),
                    Text("medical_interpretation_label".tr(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
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
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    Text("advice_and_recommendations_label".tr(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
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
