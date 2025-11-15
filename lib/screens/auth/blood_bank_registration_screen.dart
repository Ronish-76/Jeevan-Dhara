import 'package:flutter/material.dart';

class BloodBankRegistrationScreen extends StatefulWidget {
  const BloodBankRegistrationScreen({super.key});

  @override
  State<BloodBankRegistrationScreen> createState() =>
      _BloodBankRegistrationScreenState();
}

class _BloodBankRegistrationScreenState extends State<BloodBankRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _bloodBankNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _designationController = TextEditingController();

  // Step 2 Controllers & Variables
  final _storageCapacityController = TextEditingController();
  bool _isEmergencyServiceAvailable = false;
  bool _hasComponentSeparation = false;
  bool _hasApheresisService = false;

  // Step 3 Controllers & Variables
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _pageController.dispose();
    _bloodBankNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _contactPersonController.dispose();
    _designationController.dispose();
    _storageCapacityController.dispose();
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

  void _completeRegistration() {
    if (_step3FormKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must accept the terms and conditions.')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blood Bank Registration Complete!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
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
        title: Text('Blood Bank Registration', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(icon: Icon(Icons.arrow_back, color: Colors.black), onPressed: _previousPage)
            : null,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Text('Step ${_currentPage + 1} of 3', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  physics: NeverScrollableScrollPhysics(),
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
            Text('Blood Bank Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Register your blood bank to connect with donors and hospitals', style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600])),
            SizedBox(height: 24),
            _buildTextFormField(controller: _bloodBankNameController, label: 'Blood Bank Name'),
            SizedBox(height: 16),
            _buildTextFormField(controller: _emailController, label: 'Email Address', keyboardType: TextInputType.emailAddress),
            SizedBox(height: 16),
            _buildTextFormField(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone),
            SizedBox(height: 16),
            _buildTextFormField(controller: _licenseIdController, label: 'Registration/License ID'),
            SizedBox(height: 16),
            _buildTextFormField(controller: _addressController, label: 'Full Address'),
            SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextFormField(controller: _cityController, label: 'City')),
              SizedBox(width: 12),
              Expanded(child: _buildTextFormField(controller: _districtController, label: 'District')),
            ]),
            SizedBox(height: 16),
            _buildTextFormField(controller: _contactPersonController, label: 'Contact Person'),
            SizedBox(height: 16),
            _buildTextFormField(controller: _designationController, label: 'Designation'),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _nextPage, child: Text('Next: Inventory & Services'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD32F2F), padding: EdgeInsets.symmetric(vertical: 16))),
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
            Text('Inventory & Services', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Complete your profile with inventory and security', style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600])),
            SizedBox(height: 24),
            _buildTextFormField(controller: _storageCapacityController, label: 'Storage Capacity (Units)', keyboardType: TextInputType.number),
            SizedBox(height: 16),
            SwitchListTile(title: Text('24/7 Emergency Service'), value: _isEmergencyServiceAvailable, onChanged: (v) => setState(() => _isEmergencyServiceAvailable = v), activeColor: Color(0xFFD32F2F)),
            SizedBox(height: 16),
            Text('Specialized Services', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
            SwitchListTile(title: Text('Component Separation'), value: _hasComponentSeparation, onChanged: (v) => setState(() => _hasComponentSeparation = v), activeColor: Color(0xFFD32F2F)),
            SwitchListTile(title: Text('Apheresis Service'), value: _hasApheresisService, onChanged: (v) => setState(() => _hasApheresisService = v), activeColor: Color(0xFFD32F2F)),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _nextPage, child: Text('Next: Security Setup'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD32F2F), padding: EdgeInsets.symmetric(vertical: 16))),

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
            Text('Security & Compliance', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 24),
            _buildTextFormField(controller: _passwordController, label: 'Create Password', obscureText: true, validator: (v) => v!.length < 12 ? 'Password must be at least 12 characters' : null),
            SizedBox(height: 16),
            _buildTextFormField(controller: _confirmPasswordController, label: 'Confirm Password', obscureText: true, validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Regulatory Compliance', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text('I agree to the blood safety regulations and quality standards.', style: TextStyle(fontSize: 14)),
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Color(0xFFD32F2F),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(onPressed: _completeRegistration, child: Text('Complete Registration'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD32F2F), padding: EdgeInsets.symmetric(vertical: 16))),
            SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: Text('Already have an account? Login'))),
          ],
        ),
      ),
    );
  }
}
