// lib/screens/auth/login_screen.dart

// FIX: Add necessary imports for Google Sign-In flow
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import 'forgot_password_screen.dart';
import 'role_selection_screen.dart';
import 'user_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  // Manage loading states for both buttons separately
  bool _isLoading = false;
  bool _isGoogleLoading = false; // FIX: Add loading state for Google button

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // This email/password login method is correct
  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();
    try {
      await authViewModel.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // On success, AuthWrapper navigates automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FIX: Add the logic for the Google Sign-In button
  Future<void> _googleLogin() async {
    setState(() => _isGoogleLoading = true);
    final authViewModel = context.read<AuthViewModel>();
    try {
      final result = await authViewModel.signInWithGoogle();

      // After sign-in, check the result from the ViewModel
      if (result == 'new-user') {
        // This is the first time this user has signed in.
        // Navigate them to select their role.
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RoleSelectionScreen(user: user),
          ));
        }
      }
      // If result is 'existing-user', do nothing. AuthWrapper will handle it.
      // If result is 'canceled', do nothing.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32.0),
              Image.asset('assets/images/jeevan_dhara_logo.png', height: 100.0),
              const SizedBox(height: 16.0),
              const Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Sign in to your Jeevan Dhara account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.0,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 48.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.0,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              // FIX: Add the "OR" divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24.0),
              // FIX: Add the Google Sign-In Button
              ElevatedButton.icon(
                onPressed: _isGoogleLoading ? null : _googleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  elevation: 1,
                  shadowColor: Colors.black.withOpacity(0.05),
                ),
                icon: _isGoogleLoading
                    ? const SizedBox.shrink()
                    : Image.asset('assets/images/android_light_rd_na@1x.png',
                    height: 24.0), // Make sure this asset exists
                label: _isGoogleLoading
                    ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(
                  'Continue with Google',
                  style: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.0,
                      color: Color(0xFF666666),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserSelectionScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
