<<<<<<< HEAD
import 'package:jeevandhara/core/constants.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('auth/register', userData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // Determine endpoint based on user type if needed, but for now assuming requester
      // Ideally, the endpoint should be generic or passed in.
      // Given the backend change was in requesterRoutes, we use that.
      final response = await _apiService.put('requesters/$userId', updates);
      return response;
    } catch (e) {
      rethrow;
    }
=======
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
>>>>>>> map-feature
  }
}
