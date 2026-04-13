import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/storage_service.dart';
import 'screens/scan_results_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocrService = OCRService();
  final StorageService _storageService = StorageService();
  bool _isProcessing = false;

  Future<void> _processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isProcessing = true);

      String? imageUrl;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        imageUrl = await _storageService.uploadAnalysisImage(File(image.path), user.uid);
      }

      final text = await _ocrService.extractText(image.path);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultsScreen(
              extractedText: text,
              imagePath: image.path,
              imageUrl: imageUrl,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Processing error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  ///  Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Close
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                        Text(
                          "scan_title".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// الكارد
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "scan_instructions".tr(),
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1FB6A6),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  ///  الأزرار
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ///  Gallery
                        GestureDetector(
                          onTap: () => _processImage(ImageSource.gallery),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white10,
                            child: const Icon(Icons.image, color: Colors.white),
                          ),
                        ),

                        GestureDetector(
                          onTap: () => _processImage(ImageSource.camera),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1FB6A6),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                          ),
                        ),

                        /// ⚡ Flash
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white10,
                          child: const Icon(Icons.flash_on, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1FB6A6)),
                ),
              ),
          ],
        ),
    );
  }
}
