import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'settings_service.dart';

class EmailWebhookService {
  EmailWebhookService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<String?> _userEmail(String uid) async {
    // Prefer Auth email.
    final authEmail = FirebaseAuth.instance.currentUser?.email?.trim();
    if (authEmail != null && authEmail.isNotEmpty) return authEmail;

    // Fallback to users/{uid}.email (AuthService already maintains it).
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final fromDoc = (snap.data()?['email'] as String?)?.trim();
      if (fromDoc != null && fromDoc.isNotEmpty) return fromDoc;
    } catch (_) {}
    return null;
  }

  Future<void> maybeSendNotificationEmail({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    if (kIsWeb) return;
    final url = AppConfig.emailWebhookUrl.trim();
    if (url.isEmpty) return;

    final emailEnabled = await SettingsService().getEmailEnabled();
    if (!emailEnabled) return;

    final email = await _userEmail(userId);
    if (email == null) return;

    try {
      await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': email,
          'subject': title,
          'text': body,
          'userId': userId,
          if (data.isNotEmpty) 'data': data,
        }),
      );
    } catch (_) {
      // Silent failure: webhook may be offline; in-app notifications still work.
    }
  }
}

