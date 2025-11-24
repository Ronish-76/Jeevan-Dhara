// lib/viewmodels/auth_viewmodel.dart

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jeevandhara/viewmodels/base_viewmodel.dart';

/// Manages all authentication and user profile logic for the application.
/// This class acts as the single bridge between the UI and the authentication/backend services.
class AuthViewModel extends BaseViewModel {
  // Instantiate Firebase and Google services.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Your backend API's base URL.
  // Using ADB reverse port forwarding: adb reverse tcp:5000 tcp:5000
  static const String _baseUrl = 'https://jeevan-dhara-s7wo.onrender.com/api';

  // --- Core Authentication State ---

  /// A real-time stream of the user's authentication state from Firebase.
  /// The AuthWrapper listens to this stream to automatically navigate the user.
  Stream<User?> get userStream => _auth.authStateChanges();

  // --- Authentication Methods ---

  /// Signs in a user with their email and password using Firebase Auth.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      setLoading(true);
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw 'No user found for that email.';
      if (e.code == 'wrong-password') throw 'Wrong password provided for that user.';
      if (e.code == 'invalid-email') throw 'The email address is not valid.';
      throw 'Login failed. Please check your credentials.';
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    } finally {
      setLoading(false);
    }
  }

  /// Handles Google Sign-In flow.
  /// Returns a status string: 'existing-user', 'new-user', or 'canceled'.
  Future<String> signInWithGoogle() async {
    setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'canceled';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) throw 'Google Sign-In failed. Please try again.';

      final existingProfile = await getUserProfile(user.uid);

      if (existingProfile != null && existingProfile['role'] != null) {
        return 'existing-user';
      } else {
        // Create a partial profile on the backend for the new user.
        final profileData = {
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? 'New User',
          'photoUrl': user.photoURL,
        };
        final response = await http.post(
          Uri.parse('$_baseUrl/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(profileData),
        );

        if (response.statusCode != 201 && response.statusCode != 200) {
          await logout(); // Clean up on failure
          throw 'Failed to create user profile on the backend.';
        }
        return 'new-user';
      }
    } catch (e) {
      await logout(); // Clean up on any error
      print('Google Sign-In Error: $e');
      throw 'An error occurred during Google Sign-In.';
    } finally {
      setLoading(false);
    }
  }

  /// Sends a password reset email to the user via Firebase.
  Future<void> sendPasswordResetEmail({required String email}) async {
    setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw 'No user found for that email address.';
      if (e.code == 'invalid-email') throw 'The email address is not valid.';
      throw 'An error occurred. Please try again.';
    } catch (e) {
      throw 'An unexpected error occurred.';
    } finally {
      setLoading(false);
    }
  }

  /// Signs the current user out from both Firebase and Google.
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // --- User Profile Management Methods ---

  /// Registers a user with email/pass in Firebase and creates their profile on the backend.
  Future<void> registerUserAndCreateProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profileData,
  }) async {
    UserCredential? userCredential;
    setLoading(true);
    try {
      // Step 1: Create the user in Firebase.
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (userCredential.user == null) throw 'User could not be created in Firebase.';

      final String uid = userCredential.user!.uid;
      final completeProfileData = {'uid': uid, 'email': email.trim(), ...profileData};

      // Step 2: Create the user profile on your backend.
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(completeProfileData),
      );

      if (response.statusCode != 201) {
        // If backend fails, delete the Firebase user to prevent orphaned accounts.
        await userCredential.user!.delete();
        final responseBody = json.decode(response.body);
        throw 'Failed to create profile: ${responseBody['message'] ?? 'Unknown backend error'}.';
      }
      // Log the user out so they have to log in with their new credentials.
      await logout();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') throw 'This email is already registered. Please login instead.';
      if (e.code == 'weak-password') throw 'Password is too weak. Please use at least 6 characters.';
      throw 'Registration failed: ${e.message ?? "An unknown Firebase error occurred."}';
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Updates an existing user's profile on the backend (e.g., to add a role).
  Future<void> updateUserProfile(String uid, Map<String, dynamic> dataToUpdate) async {
    setLoading(true);
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/users/$uid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToUpdate),
      );
      if (response.statusCode != 200) {
        throw 'Failed to update user profile on the backend.';
      }
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Fetches the user's full profile from your backend API.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final uri = Uri.parse('$_baseUrl/users/$uid');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user'] as Map<String, dynamic>?;
      } else if (response.statusCode == 404) {
        // This case handles a new Google user who exists in Firebase Auth but not yet in our backend.
        return null;
      } else {
        print('Failed to get user profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user profile from API: $e');
      return null;
    }
  }
}
