import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
  final _step3FormKey = GlobalKey<FormState>();

  // Step 1 Controllers & Variables
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+977');
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();
  String? _bloodGroup;
  
  // Location variables
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  // Step 2 Controllers & Variables
  final _healthProblemsController = TextEditingController();
  String? _hasDonatedBefore;
  DateTime? _lastDonationDate;
  bool _isAvailable = false;
  String? _donationCapability;

  // Step 3 Controllers & Variables
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _ageController.dispose();
    _healthProblemsController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translate('location_services_disabled'))));
      setState(() => _isLoadingLocation = false);
      return;
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translate('location_permission_denied'))));
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translate('location_permission_denied'))));
      setState(() => _isLoadingLocation = false);
      return;
    }

    // Get position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) return;

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isLoadingLocation = false;
    });
    
    print("Location fetched: $_latitude, $_longitude"); 
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (_step1FormKey.currentState!.validate()) {
        // Validation to ensure location coordinates are captured
        if (_latitude == null || _longitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translate('location_coords_required')),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentPage == 1) {
       if (_step2FormKey.currentState!.validate()) {
          if (_donationCapability == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(translate('donation_capability_required')),
              ),
            );
            return;
          }
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
       }
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
      
      // Default "No" for health problems if empty
      String healthProblems = _healthProblemsController.text.trim();
      if (healthProblems.isEmpty) {
        healthProblems = "No";
      }

      final success = await authProvider.register({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'location': _locationController.text,
        'latitude': _latitude,
        'longitude': _longitude,
        'age': int.tryParse(_ageController.text),
        'bloodGroup': _bloodGroup,
        'healthProblems': healthProblems,
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
              title: Text(translate('registration_successful'), style: const TextStyle(color: Color(0xFFD32F2F))),
              content: Text(translate('account_created_msg')),
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
        _showErrorDialog(authProvider.errorMessage ?? translate('registration_failed'));
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
          title: Text(translate('registration_failed'), style: const TextStyle(color: Colors.red)),
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
    if (_step3FormKey.currentState!.validate()) {
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
            SnackBar(
              content: Text(
                translate('must_wait_3_months'),
              ),
            ),
          );
        }
      });
    }
  }

  void _changeLanguage(BuildContext context) {
    final currentLocale = LocalizedApp.of(context).delegate.currentLocale;
    if (currentLocale.languageCode == 'en') {
      changeLocale(context, 'ne');
    } else {
      changeLocale(context, 'en');
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
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
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
    var localizationDelegate = LocalizedApp.of(context).delegate;
    final isNepali = localizationDelegate.currentLocale.languageCode == 'ne';

    String pageTitle = translate('be_the_reason');
    if (_currentPage == 1) {
      pageTitle = translate('health_and_donation_readiness');
    } else if (_currentPage == 2) {
      pageTitle = translate('security');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          translate('donor_registration'),
          style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _currentPage > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _previousPage)
            : BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          TextButton.icon(
            onPressed: () => _changeLanguage(context),
            icon: const Icon(Icons.language, color: Color(0xFFD32F2F)),
            label: Text(
              isNepali ? 'English' : 'नेपाली',
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                translate('app_name'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translate('step_of', args: {'current': _currentPage + 1, 'total': 3}),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: const Color(0xFFE0E0E0),
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
      padding: const EdgeInsets.only(top: 24),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              translate('personal_details'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _nameController,
              label: translate('full_name'),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  // Capitalize the first letter of each word
                  final capitalized = value.split(' ').map((word) {
                    if (word.isNotEmpty) {
                      return word[0].toUpperCase() + word.substring(1);
                    }
                    return '';
                  }).join(' ');
                  
                  if (capitalized != value) {
                    _nameController.value = _nameController.value.copyWith(
                      text: capitalized,
                      selection: TextSelection.collapsed(offset: capitalized.length),
                    );
                  }
                }
              },
              validator: (v) => v!.isEmpty ? translate('name_required') : null,
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: translate('email'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                 // Automatically appending .com if user stops typing? 
                 // See Requester registration for logic, keeping simple here.
              },
              validator: (v) {
                if (v == null || v.isEmpty) return translate('valid_email_required');
                if (!v.contains('@')) return translate('valid_email_required');
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: translate('phone_number'),
              keyboardType: TextInputType.phone,
              // Restrict length to 14 characters (+977 + 10 digits)
              onChanged: (value) {
                if (!value.startsWith('+977')) {
                  // Force prefix
                  _phoneController.value = TextEditingValue(
                    text: '+977' + value.replaceAll('+977', ''),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) return translate('phone_required');
                if (!v.startsWith('+977')) return 'Must start with +977';
                return null;
              },
            ),
            // Password field removed from here and moved to Step 3
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _ageController,
              label: translate('age'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return translate('age_required');
                }
                final age = int.tryParse(v);
                if (age == null) {
                  return translate('valid_age_required');
                }
                if (age < 18 || age > 75) {
                  return 'Age must be between 18 and 75';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: InputDecoration(
                labelText: translate('blood_group'),
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
              validator: (v) => v == null ? translate('blood_group_required') : null,
            ),
            const SizedBox(height: 16),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _districts.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _locationController.text = selection;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                 if (textEditingController.text != _locationController.text) {
                    textEditingController.text = _locationController.text;
                 }
                 
                 textEditingController.addListener(() {
                   _locationController.text = textEditingController.text;
                 });

                 return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: translate('location_district'),
                      hintText: translate('select_district'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
                      ),
                    ),
                    validator: (v) {
                       if (v == null || v.isEmpty) return translate('location_required');
                       if (!_districts.contains(v)) return 'Please select a valid district from the list';
                       return null;
                    },
                 );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: Text(_latitude == null 
                  ? translate('get_current_location') 
                  : translate('location_saved')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _latitude == null ? Colors.grey[200] : Colors.green[100], // Visual feedback
                foregroundColor: Colors.black,
                elevation: 0,
                side: _latitude == null ? BorderSide(color: Colors.red.shade200) : null, // Red border if not set
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (_latitude == null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  translate('location_coords_required'),
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextPage,
              child: Text('${translate("next")}: ${translate("health_information")}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translate('already_have_account')),
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
              translate('health_information'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _healthProblemsController,
              label: translate('health_problems'),
              hint: translate('health_problems_hint'),
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _hasDonatedBefore,
              decoration: InputDecoration(
                labelText: translate('have_donated_before'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [translate('yes'), translate('no')].map((String value) {
                return DropdownMenuItem<String>(
                  value: value == translate('yes') ? 'Yes' : 'No',
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
              validator: (v) => v == null ? translate('field_required') : null,
            ),
            if (_hasDonatedBefore == 'Yes') ...[
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _lastDonationDate == null
                      ? translate('last_donation_date')
                      : '${translate("last_donation_date")}: ${_lastDonationDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectLastDonationDate(context),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  translate('available_for_donation'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: _isAvailable,
                onChanged: (bool value) {
                  if (value == true) {
                    if (_lastDonationDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            translate('field_required'),
                          ),
                        ),
                      );
                      return;
                    }
                    if (_lastDonationDate!.isAfter(
                      DateTime.now().subtract(const Duration(days: 90)),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            translate('must_wait_3_months'),
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
                activeColor: const Color(0xFFD32F2F),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              translate('donation_eligibility'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translate('medically_fit') + '?',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text(translate('medically_fit')),
                  value: 'Yes',
                  groupValue: _donationCapability,
                  onChanged: (value) =>
                      setState(() => _donationCapability = value),
                ),
                RadioListTile<String>(
                  title: Text(translate('not_medically_fit')),
                  value: 'No',
                  groupValue: _donationCapability,
                  onChanged: (value) =>
                      setState(() => _donationCapability = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _nextPage,
              child: Text('${translate("next")}: ${translate("security")}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24),
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              translate('security'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _passwordController,
              label: translate('create_password'),
              obscureText: !_passwordVisible,
              validator: (v) => v!.length < 8
                  ? translate('password_length_error')
                  : null,
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
              label: translate('confirm_password'),
              obscureText: !_confirmPasswordVisible,
              validator: (v) => v != _passwordController.text
                  ? translate('passwords_do_not_match')
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _confirmPasswordVisible = !_confirmPasswordVisible,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _completeRegistration,
              child: Text(translate('complete_registration')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
             const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translate('already_have_account')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
