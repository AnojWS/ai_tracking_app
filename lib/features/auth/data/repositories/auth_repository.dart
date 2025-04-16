import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Constructor allowing dependency injection
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Stream to listen for authentication state changes
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  // Get the current user ID (returns null if not logged in)
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors (e.g., user-not-found, wrong-password)
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      throw Exception(
        'Failed to sign in: ${e.message}',
      ); // Rethrow or handle differently
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors (e.g., email-already-in-use, weak-password)
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      throw Exception(
        'Failed to sign up: ${e.message}',
      ); // Rethrow or handle differently
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If the user cancelled the sign-in
      if (googleUser == null) {
        print('Google Sign-In cancelled by user.');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Exception during Google Sign-In: ${e.code} - ${e.message}',
      );
      throw Exception('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      print('Google Sign-In error: $e');
      throw Exception('An unexpected error occurred during Google Sign-In.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Also sign out from Google if the user signed in with Google
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out.');
    }
  }
}
