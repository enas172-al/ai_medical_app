import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportItem {
  final String testName;
  final String value;
  final String unit;
  final String normalRange;
  final String status;

  PdfExportItem({
    required this.testName,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.status,
  });
}

class PdfExportService {
  /// Extra profile rows (name/DOB/weight/height appear in the summary card at the top).
  static const _profileDetailKeyOrder = <String>[
    'email',
    'gender',
    'userId',
    'uid',
    'familyRole',
    'createdAt',
    'lastLogin',
  ];

  static String _displayNameFromProfile(Map<String, dynamic> m) {
    final a = m['displayName']?.toString().trim();
    final b = m['name']?.toString().trim();
    if (a != null && a.isNotEmpty) return a;
    if (b != null && b.isNotEmpty) return b;
    return '—';
  }

  static DateTime? _parseBirthDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String _formatDobDisplay(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  static int _ageYears(DateTime dob) {
    final n = DateTime.now();
    var y = n.year - dob.year;
    if (n.month < dob.month || (n.month == dob.month && n.day < dob.day)) {
      y--;
    }
    return y;
  }

  static String _numOrDash(dynamic v) {
    if (v == null) return '—';
    if (v is num) {
      final d = v.toDouble();
      if (d == d.roundToDouble()) return '${d.toInt()}';
      return d.toStringAsFixed(1);
    }
    final s = v.toString().trim();
    return s.isEmpty ? '—' : s;
  }

  static List<pw.Widget> _patientSummaryBlock({
    required Map<String, dynamic> userProfile,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    final name = _displayNameFromProfile(userProfile);
    final dob = _parseBirthDate(userProfile['dateOfBirth']);
    final ageStr = dob != null ? '${_ageYears(dob)}' : '—';
    final dobStr = dob != null ? _formatDobDisplay(dob) : '—';

    pw.Widget line(String label, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                label,
                style: pw.TextStyle(font: fontBold, fontSize: 11, color: PdfColors.teal800),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                value,
                style: pw.TextStyle(font: fontRegular, fontSize: 11),
              ),
            ),
          ],
        ),
      );
    }

    return [
      line('export_pdf_summary_name'.tr(), name),
      line('export_pdf_summary_age'.tr(), ageStr),
      line('export_pdf_summary_dob'.tr(), dobStr),
      line('export_pdf_summary_weight'.tr(), _numOrDash(userProfile['weightKg'])),
      line('export_pdf_summary_height'.tr(), _numOrDash(userProfile['heightCm'])),
    ];
  }

  static Future<String> generatePdf({
    required String title,
    required String subtitle,
    required List<PdfExportItem> items,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final tableHeaders = [
      "test_name_col".tr(),
      "value_col".tr(),
      "unit_col".tr(),
      "normal_range_col".tr(),
      "status".tr(), // Missing translation maybe? Let's use "الحالة" or just "status"
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl, // Set RTL for Arabic
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.teal)),
                    pw.SizedBox(height: 4),
                    pw.Text(subtitle, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Table
            pw.TableHelper.fromTextArray(
              headers: tableHeaders,
              data: items.map((e) => [
                e.testName,
                e.value,
                e.unit,
                e.normalRange,
                e.status,
              ]).toList(),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 1),
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 12, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellStyle: const pw.TextStyle(fontSize: 12),
              cellPadding: const pw.EdgeInsets.all(8),
              cellAlignments: {
                0: pw.Alignment.centerRight,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.center,
              },
            ),
            
            pw.SizedBox(height: 30),
            pw.Text(
              "ai_analysis_note".tr(),
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/analysis_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  /// Full account export: profile fields, medications, analyses (RTL, Cairo fonts).
  static Future<String> generateHealthDataExportPdf({
    required Map<String, dynamic> userProfile,
    required List<Map<String, dynamic>> medications,
    required List<Map<String, dynamic>> analyses,
    required String exportDateIso,
  }) async {
    String cell(dynamic v) {
      if (v == null) return '—';
      if (v is List) return v.map(cell).join('، ');
      if (v is Map) {
        return v.entries.map((e) => '${e.key}: ${cell(e.value)}').join(' | ');
      }
      return v.toString();
    }

    String normalRangeStr(dynamic n) {
      if (n is Map) {
        final min = n['min'];
        final max = n['max'];
        return '${min ?? ''}–${max ?? ''}';
      }
      return n?.toString() ?? '—';
    }

    final hasMedicalData = medications.isNotEmpty || analyses.isNotEmpty;

    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();
    final theme = pw.ThemeData.withFont(base: fontRegular, bold: fontBold);

    pw.MemoryImage? logoImage;
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {}

    List<pw.Widget> buildTitleAndLogo() {
      return [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoImage != null) ...[
              pw.Image(logoImage, width: 52, height: 52),
              pw.SizedBox(width: 12),
            ],
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'download_my_data'.tr(),
                    style: pw.TextStyle(font: fontBold, fontSize: 20, color: PdfColors.teal),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '${'export_pdf_generated_at'.tr()}: $exportDateIso',
                    style: pw.TextStyle(font: fontRegular, fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ];
    }

    List<pw.Widget> buildTopBanner() {
      return [
        ...buildTitleAndLogo(),
        pw.SizedBox(height: 12),
        ..._patientSummaryBlock(
          userProfile: userProfile,
          fontRegular: fontRegular,
          fontBold: fontBold,
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: PdfColors.teal, thickness: 0.8),
        pw.SizedBox(height: 14),
      ];
    }

    final profileData = <List<String>>[];
    for (final k in _profileDetailKeyOrder) {
      if (!userProfile.containsKey(k)) continue;
      final v = userProfile[k];
      if (v == null) continue;
      if (v is String && v.trim().isEmpty) continue;
      profileData.add([k, cell(v)]);
    }

    final medHeaders = [
      'export_pdf_med_name'.tr(),
      'export_pdf_med_dosage'.tr(),
      'export_pdf_med_times'.tr(),
      'export_pdf_med_days'.tr(),
      'export_pdf_med_active'.tr(),
    ];
    final medData = medications
        .map(
          (m) => [
            cell(m['name']),
            cell(m['dosage']),
            cell(m['times']),
            cell(m['daysOfWeek']),
            cell(m['isActive']),
          ],
        )
        .toList();

    final anaHeaders = [
      'test_name_col'.tr(),
      'value_col'.tr(),
      'unit_col'.tr(),
      'normal_range_col'.tr(),
      'export_pdf_col_status'.tr(),
      'export_pdf_col_date'.tr(),
    ];
    final anaData = analyses
        .map(
          (a) => [
            cell(a['testName']),
            cell(a['value']),
            cell(a['unit']),
            normalRangeStr(a['normalRange']),
            cell(a['status']),
            cell(a['date']),
          ],
        )
        .toList();

    final tableBorder = pw.TableBorder.all(color: PdfColors.grey300, width: 0.5);
    final headerDeco = const pw.BoxDecoration(color: PdfColors.teal);

    pw.Widget sectionTable({
      required List<String> headers,
      required List<List<String>> rows,
    }) {
      return pw.TableHelper.fromTextArray(
        headers: headers,
        data: rows,
        border: tableBorder,
        headerStyle: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.white),
        headerDecoration: headerDeco,
        cellStyle: pw.TextStyle(font: fontRegular, fontSize: 9),
        cellPadding: const pw.EdgeInsets.all(6),
        cellAlignments: {
          for (var i = 0; i < headers.length; i++) i: pw.Alignment.centerRight,
        },
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: theme,
        build: (context) {
          if (!hasMedicalData) {
            return [
              ...buildTopBanner(),
              pw.SizedBox(height: 20),
              pw.Text(
                'export_pdf_nothing_to_export'.tr(),
                style: pw.TextStyle(font: fontBold, fontSize: 16, color: PdfColors.black),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'export_pdf_nothing_hint'.tr(),
                style: pw.TextStyle(font: fontRegular, fontSize: 12, color: PdfColors.grey800),
              ),
            ];
          }

          return [
            ...buildTopBanner(),
            pw.Text(
              'export_pdf_section_profile'.tr(),
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
            pw.SizedBox(height: 8),
            if (profileData.isEmpty)
              pw.Text('export_pdf_empty'.tr(), style: const pw.TextStyle(fontSize: 11))
            else
              sectionTable(
                headers: [
                  'export_pdf_col_field'.tr(),
                  'export_pdf_col_value'.tr(),
                ],
                rows: profileData,
              ),
            pw.SizedBox(height: 20),
            pw.Text(
              'export_pdf_section_meds'.tr(),
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
            pw.SizedBox(height: 8),
            sectionTable(headers: medHeaders, rows: medData),
            pw.SizedBox(height: 20),
            pw.Text(
              'export_pdf_section_analyses'.tr(),
              style: pw.TextStyle(font: fontBold, fontSize: 14),
            ),
            pw.SizedBox(height: 8),
            sectionTable(headers: anaHeaders, rows: anaData),
            pw.SizedBox(height: 24),
            pw.Text(
              'ai_analysis_note'.tr(),
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
            ),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File(
      '${output.path}/health_data_export_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
