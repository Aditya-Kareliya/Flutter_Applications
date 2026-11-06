import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final token = await user.getIdTokenResult(true);
    return token.claims?['admin'] == true;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth sendPasswordResetEmail error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('sendPasswordResetEmail unexpected error: $e');
      rethrow;
    }
  }

  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No administrator is currently signed in.',
      );
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'Current administrator does not have an associated email.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No administrator is currently signed in.',
      );
    }
    await reauthenticate(currentPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> updateEmail({
    required String currentPassword,
    required String newEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No administrator is currently signed in.',
      );
    }
    await reauthenticate(currentPassword);
    final cleanEmail = newEmail.trim();

    // Direct email update in Firebase without requiring OTP or email link verification:
    try {
      final idToken = await user.getIdToken(true);
      final apiKey = _auth.app.options.apiKey;
      final uri = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:update?key=$apiKey',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'email': cleanEmail,
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await user.reload();
        return;
      }

      final errorData = jsonDecode(response.body);
      final errorMsg = errorData['error']?['message'] ?? 'Failed to update email in Firebase';
      if (errorMsg == 'EMAIL_EXISTS') {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address $cleanEmail is already in use by another account.',
        );
      }
      throw Exception(errorMsg);
    } catch (e) {
      rethrow;
    }
  }
}
