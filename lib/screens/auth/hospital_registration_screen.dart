import 'package:flutter/material.dart';
// FIX 1: Import the necessary ViewModel and Provider package.
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class HospitalRegistrationScreen extends StatefulWidget {
  const HospitalRegistrationScreen({super.key});

  @override
  State<HospitalRegistrationScreen> createState() =>
      _HospitalRegistrationScreenState();
}

class _HospitalRegistrationScreenState
    extends State<HospitalRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
  DateTime? _licenseExpiry;

  // Step 3 Controllers
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;

  // FIX 2: Add a loading state variable.
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all controllers
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
    switch (_currentPage) {
      case 0:
        currentFormKey = _step1FormKey;
        break;
      case 1:
        currentFormKey = _step2FormKey;
        break;
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

  // FIX 3: Implement the full, robust registration logic.
  Future<void> _completeRegistration() async {
    // 1. Validate the final form step.
    if (!_step3FormKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the terms and conditions.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authViewModel = context.read<AuthViewModel>();

    try {
      // 2. Collect all data from all steps into a single map.
      final profileData = {
        // Step 1 Data
        'name': _hospitalNameController.text.trim(),
        'officialPhone': _phoneController.text.trim(),
        'registrationId': _regIdController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'district': _districtController.text.trim(),
        'contactPerson': _contactPersonController.text.trim(),
        'contactPersonDesignation': _designationController.text.trim(),

        // Step 2 Data
        'hasBloodBank': _hasBloodBank,
        'storageCapacity': int.tryParse(_capacityController.text.trim()) ?? 0,
        'hasEmergencyService': _isEmergencyServiceAvailable,
        'hospitalType': _hospitalType,
        'licenseNumber': _licenseController.text.trim(),
        'licenseExpiryDate': _licenseExpiry?.toIso8601String(),

        // Hardcoded Role for this screen
        'role': 'hospital',
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
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      // 5. On failure, show the specific error from the ViewModel.
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

  // The rest of your UI code is already excellent and requires no changes.
  // The _buildTextFormField, build, _buildStep1, _buildStep2, and _buildStep3
  // methods are all correct.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Hospital Registration',
          style: TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _previousPage,
        )
            : null,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Step ${_currentPage + 1} of 3',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  // --- All UI Build Methods Below Are Correct ---

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hospital Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register your hospital to request or manage blood inventory',
              style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _hospitalNameController,
              label: 'Hospital Name',
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _regIdController,
              label: 'Hospital Registration ID',
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _addressController,
              label: 'Address/Location',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _cityController,
                    label: 'City',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextFormField(
                    controller: _districtController,
                    label: 'District',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _contactPersonController,
              label: 'Contact Person',
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _designationController,
              label: 'Designation',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next: Blood Inventory'),
            ),
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
            const Text(
              'Blood Inventory & Facilities',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your hospital profile and security setup',
              style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Blood Bank Facility'),
              value: _hasBloodBank,
              onChanged: (v) => setState(() => _hasBloodBank = v),
              activeColor: const Color(0xFFD32F2F),
            ),
            if (_hasBloodBank)
              _buildTextFormField(
                controller: _capacityController,
                label: 'Storage Capacity (Units)',
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('24/7 Emergency Service'),
              value: _isEmergencyServiceAvailable,
              onChanged: (v) =>
                  setState(() => _isEmergencyServiceAvailable = v),
              activeColor: const Color(0xFFD32F2F),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _hospitalType,
              decoration: InputDecoration(
                labelText: 'Hospital Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: ['Government', 'Private', 'Teaching', 'Community'].map((
                  String value,
                  ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) => setState(() => _hospitalType = newValue),
              validator: (v) => v == null ? 'Hospital Type is required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _licenseController,
              label: 'Medical License Number',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Next: Security Setup'),
            ),
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
            const Text(
              'Security & Compliance',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _passwordController,
              label: 'Create Password',
              validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              validator: (v) => v != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Legal Compliance',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text(
                      'I agree to the terms and medical regulations.',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFD32F2F),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _completeRegistration,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Complete Registration'),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Already have an account? Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
}
