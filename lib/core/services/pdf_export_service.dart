import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';

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
}
