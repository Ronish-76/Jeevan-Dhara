import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  State<HospitalRegistrationScreen> createState() =>
      _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState extends State<HospitalRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form Keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _hospitalNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _designationController = TextEditingController();

  // Step 2 Controllers & Variables
  bool _hasBloodBank = false;
  final _capacityController = TextEditingController();
  bool _isEmergencyServiceAvailable = false;
  String? _hospitalType;
  final _licenseController = TextEditingController();

  // Step 3 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;


  @override
  void dispose() {
    _pageController.dispose();
    _hospitalNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _regIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _contactPersonController.dispose();
    _designationController.dispose();
    _capacityController.dispose();
    _licenseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextPage() {
    var currentFormKey;
    switch(_currentPage) {
        case 0: currentFormKey = _step1FormKey; break;
        case 1: currentFormKey = _step2FormKey; break;
    }
    if (currentFormKey.currentState!.validate()) {
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

  Future<void> _completeRegistration() async {
    if (_step3FormKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must accept the terms and conditions.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final data = {
        'hospitalName': _hospitalNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'hospitalRegistrationId': _regIdController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'contactPerson': _contactPersonController.text,
        'bloodBankFacility': _hasBloodBank,
        'emergencyService24x7': _isEmergencyServiceAvailable,
        'hospitalType': _hospitalType?.toLowerCase(), // Enum requires lowercase
        'medicalLicenseNumber': _licenseController.text,
        'password': _passwordController.text,
      };

      try {
        await ApiService().registerHospital(data);
        if (mounted) {
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
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Registration Failed: ${e.toString().replaceAll('Exception:', '')}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD32F2F)),
        ),
      ),
      validator: validator ?? (v) => v!.isEmpty ? '$label is required' : null,
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Hospital Registration', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _previousPage)
            : BackButton(onPressed: () => Navigator.of(context).pop()),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text('Step ${_currentPage + 1} of 3', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2(), _buildStep3()],
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
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const Text('Hospital Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
             const SizedBox(height: 8),
             Text('Register your hospital to request or manage blood inventory', style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600])),
             const SizedBox(height: 24),
            _buildTextFormField(controller: _hospitalNameController, label: 'Hospital Name'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _emailController, label: 'Email Address', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _regIdController, label: 'Hospital Registration ID'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _addressController, label: 'Address/Location'),
            const SizedBox(height: 16),
            Row(children: [
                Expanded(child: _buildTextFormField(controller: _cityController, label: 'City')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextFormField(controller: _districtController, label: 'District')),
            ]),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _contactPersonController, label: 'Contact Person'),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _designationController, label: 'Designation'),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Next: Blood Inventory')),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Blood Inventory & Facilities', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
             const SizedBox(height: 8),
             Text('Complete your hospital profile and security setup', style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600])),
             const SizedBox(height: 24),
            SwitchListTile(title: const Text('Blood Bank Facility'), value: _hasBloodBank, onChanged: (v) => setState(() => _hasBloodBank = v), activeColor: const Color(0xFFD32F2F)),
            if (_hasBloodBank)
              _buildTextFormField(controller: _capacityController, label: 'Storage Capacity (Units)', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            SwitchListTile(title: const Text('24/7 Emergency Service'), value: _isEmergencyServiceAvailable, onChanged: (v) => setState(() => _isEmergencyServiceAvailable = v), activeColor: const Color(0xFFD32F2F)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _hospitalType,
              decoration: InputDecoration(labelText: 'Hospital Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: ['Government', 'Private', 'Teaching', 'Community'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _hospitalType = newValue),
               validator: (v) => v == null ? 'Hospital Type is required' : null,
            ),
             const SizedBox(height: 16),
            _buildTextFormField(controller: _licenseController, label: 'Medical License Number'),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Next: Security Setup')),

          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const Text('Security & Compliance', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
             const SizedBox(height: 24),
            _buildTextFormField(controller: _passwordController, label: 'Create Password', obscureText: true, validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _confirmPasswordController, label: 'Confirm Password', obscureText: true, validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
             const SizedBox(height: 24),
             Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text('Legal Compliance', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('I agree to the terms and medical regulations.', style: TextStyle(fontSize: 14)),
                          value: _termsAccepted,
                          onChanged: (v) => setState(() => _termsAccepted = v!),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: const Color(0xFFD32F2F),
                        ),
                    ]
                )
             ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeRegistration,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Complete Registration'),
            ),
             const SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    ), child: const Text('Already have an account? Login'))),
          ],
        ),
      ),
    );
  }
}
