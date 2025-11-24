<<<<<<< HEAD
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
=======
// lib/screens/auth/requester_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
>>>>>>> map-feature

class RequesterRegistrationScreen extends StatefulWidget {
  // This can be const again as it takes no parameters
  const RequesterRegistrationScreen({super.key});

  @override
  State<RequesterRegistrationScreen> createState() =>
      _RequesterRegistrationScreenState();
}

class _RequesterRegistrationScreenState
    extends State<RequesterRegistrationScreen> {
  // Page Controller for multi-step form
  final _pageController = PageController();
  int _currentPage = 0;

  // Form Keys for validation
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // All your text controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();
  final _hospitalController = TextEditingController();
<<<<<<< HEAD
  String? _gender;

  // Step 2 Controllers & Variables
  String? _bloodGroup;
  bool _isEmergency = false;
=======
>>>>>>> map-feature
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State for other inputs
  String? _gender;
  DateTime? _dateOfBirth;
  String? _bloodGroup;
  bool _isEmergency = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    _hospitalController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_step1FormKey.currentState!.validate()) {
      if (_gender == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a gender')));
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

<<<<<<< HEAD
  Future<void> _registerUser() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'age': int.tryParse(_ageController.text),
        'hospitalName': _hospitalController.text,
        'gender': _gender,
        'bloodGroup': _bloodGroup,
        'isEmergency': _isEmergency,
        'password': _passwordController.text,
        'userType': 'requester',
      });

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registration Successful', style: TextStyle(color: Color(0xFFD32F2F))),
              content: const Text('Your account has been created successfully. Please login to continue.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to login screen and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('OK', style: TextStyle(color: Color(0xFFD32F2F))),
                ),
              ],
            );
          },
        );
      } else {
        _showErrorDialog(authProvider.errorMessage ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An unexpected error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
=======
  // --- FIX: This method is now fully implemented and "bulletproof" ---
  Future<void> _completeRegistration() async {
    // 1. Validate the final step's form.
    if (!_step2FormKey.currentState!.validate()) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();

    try {
      // 2. Collect all data from your form controllers into a single map.
      final profileData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': _gender,
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'hospital': _hospitalController.text.trim(),
        'bloodGroup': _bloodGroup,
        'isEmergency': _isEmergency,
        'role': 'requester', // Hardcode the role for this specific screen
      };

      // 3. Call the single, unified registration method in the ViewModel.
      await authViewModel.registerUserAndCreateProfile(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profileData: profileData,
      );

      if (!mounted) return;

      // 4. On success, show confirmation and navigate back to the login screen.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      // Pop all the way back to the first screen (likely login or user selection).
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      // 5. On failure, show the specific error message from the ViewModel.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 6. Always stop the loading indicator.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // The rest of your file is perfectly fine. No other changes are needed.
  // The UI build methods (_buildStep1, _buildStep2, etc.) are well-structured.

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
>>>>>>> map-feature
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Failed', style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _completeRegistration() {
    if (_step2FormKey.currentState!.validate()) {
      _registerUser();
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? 'Enter your $label',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _currentPage == 0
        ? "Join the life-saving network"
        : "Complete your registration";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
<<<<<<< HEAD
        title: Text(
=======
        title: const Text(
>>>>>>> map-feature
          'Requester Registration',
          style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _currentPage == 1
<<<<<<< HEAD
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _previousPage)
            : BackButton(onPressed: () => Navigator.of(context).pop()),
=======
            ? IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: _previousPage)
            : null,
>>>>>>> map-feature
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
<<<<<<< HEAD
              Text(
=======
              const Text(
>>>>>>> map-feature
                'Jeevan Dhara',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
<<<<<<< HEAD
                  fontSize: 24,
=======
                  fontSize: 28,
>>>>>>> map-feature
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
<<<<<<< HEAD
              SizedBox(height: 4),
              Text(
                pageTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              SizedBox(height: 16),
=======
              const SizedBox(height: 8),
              Text(
                pageTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 24),
>>>>>>> map-feature
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Step ${_currentPage + 1} of 2',
<<<<<<< HEAD
                    style: TextStyle(
=======
                    style: const TextStyle(
>>>>>>> map-feature
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_currentPage + 1) / 2,
                backgroundColor: const Color(0xFFE0E0E0),
                valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Personal Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
<<<<<<< HEAD
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name',
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty || !v.contains('@')
                  ? 'A valid email is required'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _locationController,
              label: 'Location',
              validator: (v) => v!.isEmpty ? 'Location is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _ageController,
              label: 'Age',
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Age is required' : null,
            ),
            const SizedBox(height: 20),
            Text('Gender', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            RadioListTile<String>(
              title: const Text('Other'),
              value: 'Other',
              groupValue: _gender,
              onChanged: (value) => setState(() => _gender = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: _hospitalController,
              label: 'Hospital Name',
              validator: (v) => v!.isEmpty ? 'Hospital is required' : null,
            ),
            const SizedBox(height: 32),
=======
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name',
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty || !v.contains('@')
                  ? 'A valid email is required'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _locationController,
              label: 'Location',
              validator: (v) => v!.isEmpty ? 'Location is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _ageController,
              label: 'Age',
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Age is required' : null,
            ),
            const SizedBox(height: 16),
            Text('Gender', style: Theme.of(context).textTheme.bodyLarge),
            Row(
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const Text('Male'),
                Radio<String>(
                  value: 'Female',
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const Text('Female'),
                Radio<String>(
                  value: 'Other',
                  groupValue: _gender,
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const Text('Other'),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _dateOfBirth == null
                    ? 'Select Date of Birth'
                    : 'DOB: ${_dateOfBirth!.toLocal()}'.split(' ')[0],
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _hospitalController,
              label: 'Hospital',
              validator: (v) => v!.isEmpty ? 'Hospital is required' : null,
            ),
            const SizedBox(height: 24),
>>>>>>> map-feature
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
<<<<<<< HEAD
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: const Text(
                'Next: Select Blood Group',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
=======
              ),
              child: const Text('Next: Select Blood Group'),
>>>>>>> map-feature
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
<<<<<<< HEAD
                child: RichText(
                  text: const TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          color: Color(0xFFD32F2F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
=======
                child: const Text('Already have an account?'),
              ),
            ),
>>>>>>> map-feature
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
<<<<<<< HEAD
            Text(
=======
            const Text(
>>>>>>> map-feature
              'Blood Group & Security',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 16),
=======
            const SizedBox(height: 16),
>>>>>>> map-feature
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: InputDecoration(
                labelText: 'Required Blood Group*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
<<<<<<< HEAD
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((
                String value,
              ) {
=======
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                  .map<DropdownMenuItem<String>>((
                  String value,
                  ) {
>>>>>>> map-feature
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) => setState(() => _bloodGroup = newValue),
              validator: (v) => v == null ? 'Blood group is required' : null,
            ),
<<<<<<< HEAD
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Mark as Emergency'),
=======
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mark as Emergency'),
>>>>>>> map-feature
              value: _isEmergency,
              onChanged: (v) => setState(() => _isEmergency = v),
              secondary: Icon(
                Icons.emergency_outlined,
<<<<<<< HEAD
                color: _isEmergency ? Color(0xFFD32F2F) : null,
              ),
            ),
            SizedBox(height: 16),
=======
                color: _isEmergency ? const Color(0xFFD32F2F) : null,
              ),
            ),
            const SizedBox(height: 16),
>>>>>>> map-feature
            _buildTextFormField(
              controller: _passwordController,
              label: 'Create Password',
              obscureText: !_passwordVisible,
<<<<<<< HEAD
              validator: (v) => v!.length < 8
                  ? 'Password must be at least 8 characters'
                  : null,
=======
              validator: (v) =>
              v!.length < 8 ? 'Password must be at least 8 characters' : null,
>>>>>>> map-feature
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: !_confirmPasswordVisible,
<<<<<<< HEAD
              validator: (v) => v != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
=======
              validator: (v) =>
              v != _passwordController.text ? 'Passwords do not match' : null,
>>>>>>> map-feature
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
<<<<<<< HEAD
                  () => _confirmPasswordVisible = !_confirmPasswordVisible,
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _completeRegistration,
              child: Text('Complete Registration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD32F2F),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Already have an account? Login'),
              ),
            ),
=======
                      () => _confirmPasswordVisible = !_confirmPasswordVisible,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Complete Registration'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Already have an account? Login'),
              ),
            ),
>>>>>>> map-feature
          ],
        ),
      ),
    );
  }
}
