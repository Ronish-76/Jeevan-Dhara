import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _sendResetInstructions() {
    if (_emailController.text.isNotEmpty) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _verifyCode() {
    if (_otpController.text.isNotEmpty) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _resetPassword() {
    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
      ),
      validator: (v) => v!.isEmpty ? '$label is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildEmailStep(),
            _buildOtpStep(),
            _buildNewPasswordStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_reset, size: 64, color: Color(0xFFD32F2F)),
            const SizedBox(height: 24),
            const Text(
              'Enter your email to receive password reset instructions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 32),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _sendResetInstructions,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Send Reset Instructions'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Remember your password? Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter the verification code sent to your email',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 32),
            _buildTextFormField(
              controller: _otpController,
              label: 'Verification Code',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Verify Code'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Didn\'t receive code? Resend'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPasswordStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create your new password',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 32),
            _buildTextFormField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
