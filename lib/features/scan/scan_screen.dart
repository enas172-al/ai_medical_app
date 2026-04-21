import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/ai_parse_service.dart';
import 'screens/scan_results_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final OCRService _ocrService = OCRService();
  final StorageService _storageService = StorageService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDocumentScanner();
    });
  }

  Future<void> _startDocumentScanner() async {
    try {
      final options = DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full,
        pageLimit: 1,
        isGalleryImport: true,
      );
      final documentScanner = DocumentScanner(options: options);
      
      final result = await documentScanner.scanDocument();
      
      if (result.images != null && result.images!.isNotEmpty) {
        final imagePath = result.images!.first;
        await _processScannedImage(imagePath);
      } else {
         // User cancelled scanning completely
         if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Scanner error: $e");
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _processScannedImage(String path) async {
    try {
      setState(() => _isProcessing = true);
      
      String? imageUrl;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        imageUrl = await _storageService.uploadAnalysisImage(File(path), user.uid);
      }

      final text = await _ocrService.extractText(path);
      if (text.trim().isEmpty) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم التعرف على أي نص في الصورة.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final parsedItems = await AIParseService.parseHybrid(text);

      if (mounted) {
        if (parsedItems.isEmpty) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('no_data_found'.tr())),
          );
          Navigator.pop(context);
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultsScreen(
              extractedText: text,
              parsedItems: parsedItems,
              imagePath: path,
              imageUrl: imageUrl,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Processing error: $e");
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is Exception ? e.toString().replaceAll('Exception: ', '') : 'حدث خطأ أثناء معالجة التحليل.'),
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context); // Go back if it fails
      }
    }
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(color: Color(0xFF1FB6A6)),
              const SizedBox(height: 20),
              Text(
                "processing_analysis".tr(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
