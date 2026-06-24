import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/failures.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  const FirebaseAuthService(this._auth, this._googleSignIn);

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapError(e.code), code: e.code);
    } catch (_) {
      throw const UnknownFailure('Unexpected error during sign in.');
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapError(e.code), code: e.code);
    } catch (_) {
      throw const UnknownFailure('Unexpected error during sign up.');
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Google sign in was cancelled.', code: 'cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapError(e.code), code: e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      debugPrint('Google Sign-In Error: $e');
      throw const UnknownFailure('Unexpected error during Google sign in.');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (_) {
      throw const AuthFailure('Failed to sign out.', code: 'sign-out-failed');
    }
  }

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
    );
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':       return 'No account found with this email.';
      case 'wrong-password':       return 'Incorrect password. Please try again.';
      case 'email-already-in-use': return 'An account already exists with this email.';
      case 'weak-password':        return 'Password must be at least 6 characters.';
      case 'invalid-email':        return 'Please enter a valid email address.';
      case 'too-many-requests':    return 'Too many attempts. Try again later.';
      case 'network-request-failed': return 'No internet connection.';
      case 'operation-not-allowed':  return 'Google/Password auth is not enabled in Firebase Console.';
      default:                     return 'Authentication failed ($code). Please try again.';
    }
  }
}