import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';

class BloodBankRegistrationScreen extends StatefulWidget {
  const BloodBankRegistrationScreen({super.key});

  @override
  State<BloodBankRegistrationScreen> createState() =>
      _BloodBankRegistrationScreenState();
}

class _BloodBankRegistrationScreenState extends State<BloodBankRegistrationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form Keys
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final _bloodBankNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+977');
  final _licenseIdController = TextEditingController(text: 'NP-BB-');
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _contactPersonController = TextEditingController();
  // Designation removed

  // Step 2 Controllers & Variables
  final _storageCapacityController = TextEditingController();
  bool _isEmergencyServiceAvailable = false;
  bool _hasComponentSeparation = false;
  bool _hasApheresisService = false;

  // Step 3 Controllers & Variables
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;

  final List<String> _districts = [
    "Achham", "Arghakhanchi", "Baglung", "Baitadi", "Bajhang", "Bajura", "Banke", "Bara", "Bardiya", "Bhaktapur",
    "Bhojpur", "Chitwan", "Dadeldhura", "Dailekh", "Dang", "Darchula", "Dhading", "Dhankuta", "Dhanusa", "Dolakha",
    "Dolpa", "Doti", "Eastern Rukum", "Gorkha", "Gulmi", "Humla", "Ilam", "Jajarkot", "Jhapa", "Jumla",
    "Kailali", "Kalikot", "Kanchanpur", "Kapilvastu", "Kaski", "Kathmandu", "Kavrepalanchok", "Khotang", "Lalitpur",
    "Lamjung", "Mahottari", "Makwanpur", "Manang", "Morang", "Mugu", "Mustang", "Myagdi", "Nawalpur", "Nuwakot",
    "Okhaldhunga", "Palpa", "Panchthar", "Parasi", "Parbat", "Parsa", "Pyuthan", "Ramechhap", "Rasuwa", "Rautahat",
    "Rolpa", "Rupandehi", "Salyan", "Sankhuwasabha", "Saptari", "Sarlahi", "Sindhuli", "Sindhupalchok", "Siraha",
    "Solukhumbu", "Sunsari", "Surkhet", "Syangja", "Tanahun", "Taplejung", "Terhathum", "Udayapur", "Western Rukum"
  ];

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
    // _designationController.dispose(); // removed
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
        'bloodBankName': _bloodBankNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'registrationNumber': _licenseIdController.text,
        'fullAddress': _addressController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'contactPerson': _contactPersonController.text,
        // 'designation': _designationController.text, // removed
        'storageCapacity': int.tryParse(_storageCapacityController.text) ?? 0,
        'emergencyService24x7': _isEmergencyServiceAvailable,
        'componentSeparation': _hasComponentSeparation,
        'apheresisService': _hasApheresisService,
        'password': _passwordController.text,
      };

      try {
        await ApiService().registerBloodBank(data);
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
    void Function(String)? onChanged,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
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
        title: const Text('Blood Bank Registration', style: TextStyle(color: Colors.black, fontFamily: 'Poppins')),
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
            const Text('Blood Bank Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Register your blood bank to connect with donors and hospitals', style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600])),
            const SizedBox(height: 24),
            _buildTextFormField(
              controller: _bloodBankNameController, 
              label: 'Blood Bank Name',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final capitalized = value.split(' ').map((word) {
                    if (word.isNotEmpty) {
                      return word[0].toUpperCase() + word.substring(1);
                    }
                    return '';
                  }).join(' ');
                  
                  if (capitalized != value) {
                    _bloodBankNameController.value = _bloodBankNameController.value.copyWith(
                      text: capitalized,
                      selection: TextSelection.collapsed(offset: capitalized.length),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController, 
              label: 'Email Address', 
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'A valid email is required';
                if (!v.contains('@')) return 'A valid email is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController, 
              label: 'Phone Number', 
              keyboardType: TextInputType.phone,
              // Removed length limit as per request
              onChanged: (value) {
                if (!value.startsWith('+977')) {
                  _phoneController.value = TextEditingValue(
                    text: '+977' + value.replaceAll('+977', ''),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) return 'Phone number is required';
                if (!v.startsWith('+977')) return 'Must start with +977';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _licenseIdController, 
              label: 'Registration/License ID',
              onChanged: (value) {
                if (!value.startsWith('NP-BB-')) {
                   _licenseIdController.value = TextEditingValue(
                    text: 'NP-BB-' + value.replaceAll('NP-BB-', ''),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) return 'Registration ID is required';
                // Format: NP-BB-XXXX
                final regExp = RegExp(r'^NP-BB-\d{4}$');
                if (!regExp.hasMatch(v)) {
                  return 'Format must be NP-BB-XXXX (e.g. NP-BB-1234)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(controller: _addressController, label: 'Full Address'),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTextFormField(controller: _cityController, label: 'City')),
              const SizedBox(width: 12),
              Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text == '') {
                        return const Iterable<String>.empty();
                      }
                      return _districts.where((String option) {
                        return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      _districtController.text = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      // Sync controllers
                      if (_districtController.text.isNotEmpty && textEditingController.text.isEmpty) {
                          textEditingController.text = _districtController.text;
                      }
                      textEditingController.addListener(() {
                        _districtController.text = textEditingController.text;
                      });
                      
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'District',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                          ),
                        ),
                        validator: (v) {
                           if (v == null || v.isEmpty) return 'District is required';
                           if (!_districts.contains(v)) return 'Select valid district';
                           return null;
                        },
                      );
                    },
                  )
              ),
            ]),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _contactPersonController, 
              label: 'Contact Person',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  final capitalized = value.split(' ').map((word) {
                    if (word.isNotEmpty) {
                      return word[0].toUpperCase() + word.substring(1);
                    }
                    return '';
                  }).join(' ');
                  
                  if (capitalized != value) {
                    _contactPersonController.value = _contactPersonController.value.copyWith(
                      text: capitalized,
                      selection: TextSelection.collapsed(offset: capitalized.length),
                    );
                  }
                }
              },
            ),
            // Designation field removed
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _nextPage, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Next: Inventory & Services')),
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
            const Text('Inventory & Services', style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Complete your profile with inventory and security', style: TextStyle(fontFamily: 'Inter', color: Colors.grey[600])),
            const SizedBox(height: 24),
            _buildTextFormField(controller: _storageCapacityController, label: 'Storage Capacity (Units)', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            SwitchListTile(title: const Text('24/7 Emergency Service'), value: _isEmergencyServiceAvailable, onChanged: (v) => setState(() => _isEmergencyServiceAvailable = v), activeColor: const Color(0xFFD32F2F)),
            const SizedBox(height: 16),
            const Text('Specialized Services', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
            SwitchListTile(title: const Text('Component Separation'), value: _hasComponentSeparation, onChanged: (v) => setState(() => _hasComponentSeparation = v), activeColor: const Color(0xFFD32F2F)),
            SwitchListTile(title: const Text('Apheresis Service'), value: _hasApheresisService, onChanged: (v) => setState(() => _hasApheresisService = v), activeColor: const Color(0xFFD32F2F)),
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Regulatory Compliance', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('I agree to the blood safety regulations and quality standards.', style: TextStyle(fontSize: 14)),
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
