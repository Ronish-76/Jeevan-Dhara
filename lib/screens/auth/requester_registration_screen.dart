import 'package:flutter/material.dart';

class RequesterRegistrationScreen extends StatefulWidget {
  const RequesterRegistrationScreen({super.key});

  @override
  State<RequesterRegistrationScreen> createState() =>
      _RequesterRegistrationScreenState();
}

class _RequesterRegistrationScreenState
    extends State<RequesterRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1 Controllers & Variables
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();
  final _hospitalController = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;

  // Step 2 Controllers & Variables
  String? _bloodGroup;
  bool _isEmergency = false;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

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
    if (_step2FormKey.currentState!.validate()) {
      // Registration logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Complete!')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
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
        ? "Join the life-saving network"
        : "Complete your registration";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Requester Registration', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        leading: _currentPage == 1
            ? IconButton(icon: Icon(Icons.arrow_back), onPressed: _previousPage)
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Jeevan Dhara',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F))),
              SizedBox(height: 8),
              Text(pageTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Color(0xFF666666))),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Step ${_currentPage + 1} of 2', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
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
            Text('Personal Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            _buildTextFormField(controller: _nameController, label: 'Full Name', validator: (v) => v!.isEmpty ? 'Name is required' : null),
            SizedBox(height: 16),
            _buildTextFormField(controller: _emailController, label: 'Email Address', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'A valid email is required' : null),
            SizedBox(height: 16),
            _buildTextFormField(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Phone number is required' : null),
            SizedBox(height: 16),
            _buildTextFormField(controller: _locationController, label: 'Location', validator: (v) => v!.isEmpty ? 'Location is required' : null),
             SizedBox(height: 16),
            _buildTextFormField(controller: _ageController, label: 'Age', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Age is required' : null),
            SizedBox(height: 16),
             Text('Gender', style: Theme.of(context).textTheme.bodyLarge),
            Row(children: [
              Radio<String>(value: 'Male', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)), Text('Male'),
              Radio<String>(value: 'Female', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)), Text('Female'),
              Radio<String>(value: 'Other', groupValue: _gender, onChanged: (v) => setState(() => _gender = v)), Text('Other'),
            ]),
            SizedBox(height: 16),
            ListTile(
              title: Text(_dateOfBirth == null ? 'Select Date of Birth' : 'DOB: ${_dateOfBirth!.toLocal()}'.split(' ')[0]),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
             SizedBox(height: 16),
            _buildTextFormField(controller: _hospitalController, label: 'Hospital', validator: (v) => v!.isEmpty ? 'Hospital is required' : null),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _nextPage, child: Text('Next: Select Blood Group'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD32F2F), padding: EdgeInsets.symmetric(vertical: 16))),
             SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Already have an account?'))),
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
            Text('Blood Group & Security', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: InputDecoration(labelText: 'Required Blood Group*', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _bloodGroup = newValue),
              validator: (v) => v == null ? 'Blood group is required' : null,
            ),
            SizedBox(height: 16),
            SwitchListTile(title: Text('Mark as Emergency'), value: _isEmergency, onChanged: (v) => setState(() => _isEmergency = v), secondary: Icon(Icons.emergency_outlined, color: _isEmergency ? Color(0xFFD32F2F): null)),
             SizedBox(height: 16),
            _buildTextFormField(
              controller: _passwordController,
              label: 'Create Password',
              obscureText: !_passwordVisible,
              validator: (v) => v!.length < 8 ? 'Password must be at least 8 characters' : null,
              suffixIcon: IconButton(icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _passwordVisible = !_passwordVisible)),
            ),
            SizedBox(height: 16),
            _buildTextFormField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: !_confirmPasswordVisible,
              validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
              suffixIcon: IconButton(icon: Icon(_confirmPasswordVisible ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible)),
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: _completeRegistration, child: Text('Complete Registration'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD32F2F), padding: EdgeInsets.symmetric(vertical: 16))),
             SizedBox(height: 16),
            Center(child: TextButton(onPressed: () => Navigator.pop(context), child: Text('Already have an account? Login'))),
          ],
        ),
      ),
    );
  }
}
