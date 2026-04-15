import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// ML Kit text recognition (Latin script). Arabic-only reports are often read
/// poorly; the UI explains this when extraction returns empty.
class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text.trim();
      if (text.isEmpty && kDebugMode) {
        debugPrint('OCR: no text recognized (Latin script only; Arabic labels may be skipped).');
      }
      return text;
    } catch (e, st) {
      debugPrint('OCR Error: $e\n$st');
      return '';
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}
