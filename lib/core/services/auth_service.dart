import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import 'family_link_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FamilyLinkService _familyLink = FamilyLinkService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Updates `users/{uid}` after any successful sign-in (including MFA second step).
  Future<void> mergeUserDocumentOnSignIn(User user, {String? emailFallback}) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'userId': user.uid,
      'email': user.email ?? emailFallback,
      'lastLogin': FieldValue.serverTimestamp(),
      if (user.displayName != null) 'displayName': user.displayName,
      if (user.displayName != null) 'name': user.displayName,
    }, SetOptions(merge: true));
  }

  Future<void> _applyFamilyLinkIfPresent(User u, String? rawCode) async {
    if (rawCode == null || rawCode.trim().isEmpty) return;
    await _familyLink.linkDependentAccount(
      dependentUid: u.uid,
      email: u.email,
      displayName: u.displayName,
      rawCode: rawCode,
    );
  }

  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    /// If set (e.g. family invite code), account is treated as a dependent / child profile.
    String? familyLinkCode,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update the Firebase Auth User profile so the name appears across the app
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        
        final uid = credential.user!.uid;
        final linked =
            familyLinkCode != null && familyLinkCode.trim().isNotEmpty;

        if (linked) {
          await _db.collection('users').doc(uid).set({
            'uid': uid,
            'userId': uid,
            'email': email,
            'name': name,
            'displayName': name,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
          try {
            await _familyLink.linkDependentAccount(
              dependentUid: uid,
              email: email,
              displayName: name,
              rawCode: familyLinkCode,
            );
          } catch (e) {
            await credential.user?.delete();
            rethrow;
          }
        } else {
          await _db.collection('users').doc(uid).set({
            'uid': uid,
            'userId': uid,
            'email': email,
            'name': name,
            'displayName': name,
            'familyRole': 'guardian',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }
      return credential;
    } catch (e) {
      print("Error registering: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
    String? familyLinkCode,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final u = credential.user!;
        await mergeUserDocumentOnSignIn(u, emailFallback: email);
        await _applyFamilyLinkIfPresent(u, familyLinkCode);
      }
      return credential;
    } catch (e) {
      print("Error signing in: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle({String? familyLinkCode}) async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw Exception(
          "Google Sign-In غير مهيأ بشكل صحيح. "
          "تأكد من إضافة SHA-1 (و SHA-256) للتطبيق في Firebase ثم أعد تنزيل ملف google-services.json.",
        );
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final u = userCredential.user!;
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        try {
          await mergeUserDocumentOnSignIn(u);
          await _applyFamilyLinkIfPresent(u, familyLinkCode);
        } on FamilyLinkException catch (_) {
          if (isNewUser) {
            try {
              await u.delete();
            } catch (_) {}
          }
          rethrow;
        }
      }
      return userCredential;
    } on PlatformException catch (e) {
      final msg = (e.message ?? e.toString());
      // Most common: com.google.android.gms.common.api.ApiException: 10 (DEVELOPER_ERROR)
      if (msg.contains('ApiException: 10') || msg.contains('api_exception: 10') || msg.contains('DEVELOPER_ERROR')) {
        throw Exception(
          "فشل تسجيل الدخول بجوجل بسبب إعدادات Firebase/Google OAuth (ApiException:10). "
          "الحل: أضف SHA-1 (و SHA-256) وفعّل Google provider ثم نزّل google-services.json من جديد.",
        );
      }
      rethrow;
    } catch (e) {
      print("Error signing in with Google: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error resetting password: $e");
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
