import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

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
        final uid = credential.user!.uid;
        final linked = familyLinkCode != null && familyLinkCode.trim().isNotEmpty;
        await _db.collection('users').doc(uid).set({
          'uid': uid,
          'userId': uid,
          'email': email,
          'name': name,
          'displayName': name,
          'familyRole': linked ? 'dependent' : 'guardian',
          if (linked) 'linkedFamilyCode': familyLinkCode.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
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
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final u = credential.user!;
        await _db.collection('users').doc(u.uid).set({
          'uid': u.uid,
          'userId': u.uid,
          'email': u.email ?? email,
          'lastLogin': FieldValue.serverTimestamp(),
          if (u.displayName != null) 'displayName': u.displayName,
          if (u.displayName != null) 'name': u.displayName,
        }, SetOptions(merge: true));
      }
      return credential;
    } catch (e) {
      print("Error signing in: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final u = userCredential.user!;
        final uid = u.uid;
        final dn = u.displayName;
        await _db.collection('users').doc(uid).set({
          'uid': uid,
          'userId': uid,
          'email': u.email,
          'lastLogin': FieldValue.serverTimestamp(),
          if (dn != null) 'displayName': dn,
          if (dn != null) 'name': dn,
        }, SetOptions(merge: true));
      }
      return userCredential;
    } catch (e) {
      print("Error signing in with Google: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }
}
