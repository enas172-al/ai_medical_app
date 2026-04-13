import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Save user to Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print("Error during Google Sign In: $e");
      rethrow;
    }
  }

  // Register with Email and Password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update Firebase profile
        await userCredential.user!.updateDisplayName(name);
        
        // Let's pass a user with the updated name for Firestore saving
        // Reload is needed to reflect the new displayName in the currentUser object,
        // but we can just pass the name directly into the Firestore payload.
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'displayName': name,
          'photoURL': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      print("Error during Email/Password registration: $e");
      rethrow;
    }
  }

  // Save or update user data in Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      
      // Check if user already exists
      final docSnapshot = await userRef.get();
      
      if (!docSnapshot.exists) {
        // First time sign up
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Existing user, just update last login
        await userRef.update({
          'lastLogin': FieldValue.serverTimestamp(),
          'displayName': user.displayName ?? docSnapshot.data()?['displayName'],
          'photoURL': user.photoURL ?? docSnapshot.data()?['photoURL'],
        });
      }
    } catch (e) {
      print("Error saving user to Firestore: $e");
      // Not rethrowing as auth succeeded, but we should log it
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
