import 'package:firebase_auth/firebase_auth.dart';

/// AuthService - Handles ONLY Firebase Authentication
/// User data is stored in MongoDB via the backend API
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login with email and password
  /// Returns Firebase User object only - profile fetched from backend
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user == null) {
        throw Exception('Login failed: User not found.');
      }
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  /// Register a new user in Firebase Auth only
  /// User profile must be created separately via backend API
  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user == null) {
        throw Exception('Registration failed: Could not create user.');
      }
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  /// Get current authenticated user from Firebase
  /// Returns null if not logged in
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Password reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Get Firebase ID token for authenticated requests to backend
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }
}
