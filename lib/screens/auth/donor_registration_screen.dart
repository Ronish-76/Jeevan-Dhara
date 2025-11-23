import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';

class DonorRegistrationScreen extends StatefulWidget {
  const DonorRegistrationScreen({super.key});

  @override
  State<DonorRegistrationScreen> createState() =>
      _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1 Controllers & Variables
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();
  String? _bloodGroup;

  // Step 2 Controllers & Variables
  final _healthProblemsController = TextEditingController();
  String? _hasDonatedBefore;
  DateTime? _lastDonationDate;
  bool _isAvailable = false;
  String? _donationCapability;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    _healthProblemsController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_step1FormKey.currentState!.validate()) {
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

  Future<void> _registerUser() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'location': _locationController.text,
        'age': int.tryParse(_ageController.text),
        'bloodGroup': _bloodGroup,
        'healthProblems': _healthProblemsController.text,
        'lastDonationDate': _lastDonationDate?.toIso8601String(),
        'isAvailable': _isAvailable,
        'donationCapability': _donationCapability,
        'userType': 'donor',
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
      if (_donationCapability == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please specify if you are medically fit to donate.'),
          ),
        );
        return;
      }
      _registerUser();
    }
  }

  Future<void> _selectLastDonationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastDonationDate = picked;
        if (picked.isBefore(
          DateTime.now().subtract(const Duration(days: 90)),
        )) {
          _isAvailable = true;
        } else {
          _isAvailable = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Donors must wait 3 months between donations. Availability set to No.',
              ),
            ),
          );
        }
      });
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = _currentPage == 0
        ? "Be the reason for someone's heartbeat"
        : "Health & Donation Readiness";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Donor Registration',
          style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: _currentPage == 1
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _previousPage)
            : BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Jeevan Dhara',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              SizedBox(height: 8),
              Text(
                pageTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Step ${_currentPage + 1} of 2',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_currentPage + 1) / 2,
                backgroundColor: Color(0xFFE0E0E0),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: NeverScrollableScrollPhysics(),
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
            Text(
              'Personal & Account Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name',
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty || !v.contains('@')
                  ? 'A valid email is required'
                  : null,
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Phone number is required' : null,
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              validator: (v) => v!.length < 8
                  ? 'Password must be at least 8 characters'
                  : null,
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _ageController,
              label: 'Age',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Age is required';
                }
                final age = int.tryParse(v);
                if (age == null) {
                  return 'Please enter a valid number';
                }
                if (age < 18) {
                  return 'You must be at least 18 years old to donate';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: InputDecoration(
                labelText: 'Blood Group',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) => setState(() => _bloodGroup = newValue),
              validator: (v) => v == null ? 'Blood group is required' : null,
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _locationController,
              label: 'Location/Address',
              validator: (v) => v!.isEmpty ? 'Location is required' : null,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextPage,
              child: Text('Next: Health & Donation Readiness'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD32F2F),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Already have an account?'),
              ),
            ),
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
            Text(
              'Health Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _healthProblemsController,
              label: 'Health Problems (Optional)',
              hint: 'List any medical conditions',
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _hasDonatedBefore,
              decoration: InputDecoration(
                labelText: 'Have you donated blood before?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Yes', 'No'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _hasDonatedBefore = value;
                  if (value == 'No') {
                    _isAvailable = true;
                    _lastDonationDate = null;
                  } else {
                    _isAvailable = false;
                  }
                });
              },
              validator: (v) => v == null ? 'This field is required' : null,
            ),
            if (_hasDonatedBefore == 'Yes') ...[
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  _lastDonationDate == null
                      ? 'Last Donation Date'
                      : 'Last Donated: ${_lastDonationDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectLastDonationDate(context),
              ),
              SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Available for Donation',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isAvailable,
                onChanged: (bool value) {
                  if (value == true) {
                    if (_lastDonationDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a last donation date first.',
                          ),
                        ),
                      );
                      return;
                    }
                    if (_lastDonationDate!.isAfter(
                      DateTime.now().subtract(const Duration(days: 90)),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You cannot be available for donation as your last donation was within 3 months.',
                          ),
                        ),
                      );
                      return;
                    }
                  }
                  setState(() {
                    _isAvailable = value;
                  });
                },
                activeColor: Color(0xFFD32F2F),
              ),
            ],
            SizedBox(height: 24),
            Text(
              'Donation Eligibility',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Are you medically fit to donate blood?',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Yes - I am medically fit to donate'),
                  value: 'Yes',
                  groupValue: _donationCapability,
                  onChanged: (value) =>
                      setState(() => _donationCapability = value),
                ),
                RadioListTile<String>(
                  title: const Text('No - I am not currently fit to donate'),
                  value: 'No',
                  groupValue: _donationCapability,
                  onChanged: (value) =>
                      setState(() => _donationCapability = value),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _completeRegistration,
              child: Text('Register'),
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
          ],
        ),
      ),
    );
  }
}
