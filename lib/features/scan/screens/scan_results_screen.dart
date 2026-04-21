import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

import '../../../core/models/analysis_model.dart';
import '../../../core/models/parsed_lab_candidate.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/lab_parse_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/processing_service.dart';
import '../../../core/services/notifications_repository.dart';
import 'package:flutter/services.dart';
import '../../../core/services/pdf_export_service.dart';

class ScanResultsScreen extends StatefulWidget {
  final String? extractedText;
  final String? imagePath;
  final String? imageUrl;
  final List<ParsedLabCandidate> parsedItems;

  const ScanResultsScreen({
    super.key,
    this.extractedText,
    this.imagePath,
    this.imageUrl,
    required this.parsedItems,
  });

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  final DatabaseService _db = DatabaseService();
  late List<ParsedLabCandidate> _items;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = widget.parsedItems;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Low':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Low':
        return 'low_status'.tr();
      case 'High':
        return 'high_status'.tr();
      default:
        return 'normal_status'.tr();
    }
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "مشاركة النتائج",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF1FB6A6).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.copy, color: Color(0xFF1FB6A6)),
                  ),
                  title: const Text('نسخ كنص', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final buf = StringBuffer();
                    buf.writeln("مشاركة النتائج\n");
                    for (final c in _items) {
                      buf.writeln('${c.nameKey.tr()}: ${c.value} ${c.unit} — ${_statusLabel(c.status)}');
                    }
                    await Clipboard.setData(ClipboardData(text: buf.toString()));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ النص إلى الحافظة!')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: const Text('حفظ كـ PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final items = _items.map((c) => PdfExportItem(
                        testName: c.nameKey.tr(),
                        value: c.value.toString(),
                        unit: c.unit,
                        normalRange: '${c.min}-${c.max}',
                        status: _statusLabel(c.status),
                      )).toList();
                      final path = await PdfExportService.generatePdf(
                        title: "نتائج التحاليل",
                        subtitle: "تقرير التحليل من تطبيق Labby",
                        items: items,
                      );
                      await Share.shareXFiles([XFile(path)], text: 'تقرير نتائج التحاليل');
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('حدث خطأ أثناء إنشاء PDF: $e')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('login_to_save_results'.tr())),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      var hasAbnormal = false;
      for (final c in _items) {
        if (c.status == 'Low' || c.status == 'High') hasAbnormal = true;
        final explanation = ProcessingService.simplifiedExplanation(
          testName: c.testName,
          status: c.status,
          value: c.value,
          min: c.min,
          max: c.max,
          unit: c.unit,
        );
        await _db.addAnalysis(
          AnalysisModel(
            userId: uid,
            testName: c.testName,
            value: c.value,
            unit: c.unit,
            normalRange: c.normalRange,
            status: c.status,
            date: now,
            imageUrl: widget.imageUrl,
            simplifiedExplanation: explanation,
          ),
        );
      }
      if (hasAbnormal) {
        // Persist an in-app notification so it appears in Firestore-backed UI.
        await NotificationsRepository().addForUser(
          userId: uid,
          title: 'lab_alert_title'.tr(),
          body: 'lab_alert_body'.tr(),
          type: 'analysis',
          data: {
            if (widget.imageUrl != null) 'imageUrl': widget.imageUrl,
          },
          createdAt: now,
        );
        await NotificationService.instance.showImmediate(
          title: 'lab_alert_title'.tr(),
          body: 'lab_alert_body'.tr(),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('results_saved'.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _items;

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
                    if (widget.imagePath != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: FileImage(File(widget.imagePath!)),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    Text(
                      widget.extractedText != null && widget.extractedText!.isNotEmpty
                          ? "analysis_summary".tr()
                          : "labby_title".tr(),
                      style: const TextStyle(
                          color: Color(0xFF1FB6A6), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (widget.extractedText != null && widget.extractedText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "ocr_info_msg".tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      )
                    else
                      Text(
                        "example_dob".tr(),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showShareBottomSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: _buildActionButton(Icons.share_outlined, "share".tr(), Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _saving ? null : _saveToFirestore,
                        borderRadius: BorderRadius.circular(12),
                        child: Opacity(
                          opacity: _saving ? 0.5 : 1,
                          child: _buildActionButton(Icons.save_outlined, "save".tr(), Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

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

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final c = results[index];
                  final color = _statusColor(c.status);
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
                              Text(c.nameKey.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(c.subNameKey.tr(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 2, child: Text('${c.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Expanded(flex: 2, child: Text(c.unit, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                        Expanded(
                            flex: 2,
                            child: Text('${c.min}-${c.max}', style: const TextStyle(fontSize: 11, color: Colors.grey))),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(
                            c.status == 'Normal'
                                ? Icons.check
                                : (c.status == 'High' ? Icons.trending_up : Icons.trending_down),
                            color: color,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

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

              ...results.asMap().entries.map((e) => _buildDetailCard(e.value, '${e.key + 1}')),

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

  Widget _buildDetailCard(ParsedLabCandidate c, String idLabel) {
    final color = _statusColor(c.status);
    final label = _statusLabel(c.status);
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(c.status == 'Normal' ? Icons.check_circle_outline : Icons.error_outline,
                          color: color, size: 14),
                      const SizedBox(width: 4),
                      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(c.nameKey.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(c.subNameKey.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 16),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFF1FB6A6), shape: BoxShape.circle),
                  child: Center(child: Text(idLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildMetricItem("normal_range_label".tr(), "${c.unit} ${c.min}-${c.max}")),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricItem("measured_value_label".tr(), "${c.unit} ${c.value}")),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
                    Text("medical_interpretation_label".tr(),
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.interpretationKey.tr(),
                    style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 13, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                    Text("advice_and_recommendations_label".tr(),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(c.adviceKey.tr(), style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 13, height: 1.5)),
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
