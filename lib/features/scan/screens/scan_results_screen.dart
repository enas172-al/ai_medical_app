import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;

// NOTE: keep this screen lightweight; PDF export is handled elsewhere.
import '../../../core/models/analysis_model.dart';
import '../../../core/models/parsed_lab_candidate.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/lab_parse_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/processing_service.dart';
import '../../../core/services/notifications_repository.dart';

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
  late String _ocrText;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ocrText = widget.extractedText ?? '';
    // Prefer the backend NER/AI results passed from ScanScreen; fall back to local parsing if needed.
    _items = widget.parsedItems.isNotEmpty ? widget.parsedItems : LabParseService.parse(_ocrText);
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

  Future<void> _shareResults() async {
    final buf = StringBuffer();
    for (final c in _items) {
      buf.writeln('${c.nameKey.tr()}: ${c.value} ${c.unit} — ${_statusLabel(c.status)}');
    }
    await SharePlus.instance.share(ShareParams(text: buf.toString()));
  }

  Future<void> _saveToFirestore() async {
    if (_items.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('scan_no_tests_hint'.tr())),
        );
      }
      return;
    }
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
          severity: c.severity,
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
    final hasOcrText = _ocrText.isNotEmpty;
    final fromScan = widget.imagePath != null;
    final summaryTitle = !fromScan && !hasOcrText
        ? "labby_title".tr()
        : (!hasOcrText
            ? "scan_ocr_empty_title".tr()
            : (results.isEmpty ? "scan_no_tests_title".tr() : "analysis_summary".tr()));
    final summaryAccent =
        results.isEmpty ? Colors.orange.shade800 : const Color(0xFF1FB6A6);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.black12,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/logo.png', width: 44, height: 44),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imagePath != null) ...[
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  elevation: 2,
                  shadowColor: Colors.black26,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 200),
                      color: const Color(0xFFF0F4F8),
                      child: Image.file(
                        File(widget.imagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                elevation: 1,
                shadowColor: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: summaryAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          results.isNotEmpty ? Icons.fact_check_outlined : Icons.document_scanner_outlined,
                          color: summaryAccent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summaryTitle,
                              style: TextStyle(
                                color: summaryAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                height: 1.25,
                              ),
                            ),
                            if (hasOcrText && results.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'scan_extracted_count'.tr(namedArgs: {'count': '${results.length}'}),
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Text(
                              !fromScan && !hasOcrText
                                  ? "example_dob".tr()
                                  : (!hasOcrText
                                      ? "scan_ocr_empty_body".tr()
                                      : (results.isEmpty
                                          ? "scan_no_tests_hint".tr()
                                          : "ocr_info_msg".tr())),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.ios_share_rounded,
                      label: "share".tr(),
                      filled: false,
                      onTap: _shareResults,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.save_rounded,
                      label: "save".tr(),
                      filled: true,
                      busy: _saving,
                      onTap: _saving ? null : _saveToFirestore,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                "scan_table_section_title".tr(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 10),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 1,
                shadowColor: Colors.black12,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1FB6A6).withOpacity(0.14),
                            const Color(0xFF1FB6A6).withOpacity(0.06),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "test_name_col".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "value_col".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "unit_col".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "normal_range_col".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 28),
                        ],
                      ),
                    ),
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                        child: Text(
                          "scan_no_tests_hint".tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, index) {
                          final c = results[index];
                          final color = _statusColor(c.status);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.nameKey.tr(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(c.subNameKey.tr(),
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${c.value}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    c.unit,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${c.min}-${c.max}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    c.status == 'Normal'
                                        ? Icons.check_rounded
                                        : (c.status == 'High' ? Icons.trending_up_rounded : Icons.trending_down_rounded),
                                    color: color,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1FB6A6), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "interpretations_and_advice".tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (results.isEmpty)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      "scan_no_tests_hint".tr(),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.45),
                    ),
                  ),
                )
              else
                ...results.asMap().entries.map((e) => _buildDetailCard(e.value, '${e.key + 1}')),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool filled,
    VoidCallback? onTap,
    bool busy = false,
  }) {
    final primary = const Color(0xFF1FB6A6);
    return Material(
      color: filled ? primary : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: filled ? 2 : 0,
      shadowColor: filled ? primary.withOpacity(0.35) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled ? null : Border.all(color: Colors.grey.shade300, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: filled ? Colors.white : primary,
                  ),
                )
              else
                Icon(icon, size: 20, color: filled ? Colors.white : const Color(0xFF374151)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: filled ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
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
