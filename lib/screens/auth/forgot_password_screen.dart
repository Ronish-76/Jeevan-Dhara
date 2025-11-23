// lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
// FIX 1: Import the necessary ViewModel and Provider package.
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // FIX 2: Add loading state.
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // FIX 3: Implement the full logic to call the ViewModel.
  Future<void> _sendResetInstructions() async {
    // 1. Validate the form.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();

    try {
      // 2. Call the new method in the ViewModel.
      await authViewModel.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      // 3. On success, show a confirmation message and then pop.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Please check your email.'),
          backgroundColor: Colors.green,
        ),
      );
      // After a short delay, go back to the login screen.
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });

    } catch (e) {
      // 4. On failure, show the error from the ViewModel.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 5. Always stop the loading indicator.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX 4: The UI is now a single, simpler screen.
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.lock_reset, size: 64, color: Color(0xFFD32F2F)),
                const SizedBox(height: 24),
                const Text(
                  'Enter your registered email below to receive password reset instructions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'you@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value) =>
                  (value?.isEmpty ?? true) || !value!.contains('@')
                      ? 'Please enter a valid email'
                      : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendResetInstructions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text('Send Reset Link'),
                ),
                const Spacer(), // Pushes the button below to the bottom
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Sign In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
