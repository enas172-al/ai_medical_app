import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class StorageService {
  static const _imgbbApiKey = '36e6064879e6caa5dfaded6f770a6dd7';

  Future<String?> _uploadToImgBB(File image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.imgbb.com/1/upload?key=$_imgbbApiKey"),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception("ImgBB Upload failed: ${response.statusCode}");
      }

      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      return data["data"]["url"];
    } catch (e) {
      debugPrint('Error uploading to ImgBB: $e');
      rethrow;
    }
  }

  Future<String?> uploadAnalysisImage(File image, String userId) async {
    // userId is ignored since ImgBB is anonymous relative to the user
    return await _uploadToImgBB(image);
  }

  Future<String?> uploadMedicationImage(File image, String userId) async {
    // userId is ignored since ImgBB is anonymous relative to the user
    return await _uploadToImgBB(image);
  }

  Future<void> deleteImage(String imageUrl) async {
    // No-op: ImgBB free plan does not support direct deletion via the upload endpoint.
  }
}
