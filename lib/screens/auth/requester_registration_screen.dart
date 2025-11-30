import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
  final _phoneController = TextEditingController(text: '+977');
  final _locationController = TextEditingController();
  final _ageController = TextEditingController();
  final _hospitalController = TextEditingController();
  String? _gender;
  
  // Location variables
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  // Step 2 Controllers & Variables
  String? _bloodGroup;
  bool _isEmergency = false; 
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
    _locationController.dispose();
    _ageController.dispose();
    _hospitalController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to get location.')));
    }
  }

  void _nextPage() {
    if (_step1FormKey.currentState!.validate()) {
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate('location_coords_required')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_gender == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(translate('select_gender'))));
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

  Future<void> _registerUser() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register({
        'fullName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'latitude': _latitude,
        'longitude': _longitude,
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
              title: Text(translate('registration_successful'), style: const TextStyle(color: Color(0xFFD32F2F))),
              content: Text(translate('account_created_msg')),
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
    if (_step2FormKey.currentState!.validate()) {
      _registerUser();
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
        hintText: hint ?? '${translate("enter_email").split(" ").first} $label', // Fallback hint
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
    var localizationDelegate = LocalizedApp.of(context).delegate;
    final isNepali = localizationDelegate.currentLocale.languageCode == 'ne';

    final pageTitle = _currentPage == 0
        ? translate('join_life_saving_network')
        : translate('complete_your_registration');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          translate('requester_registration'),
          style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _currentPage == 1
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                translate('app_name'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pageTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translate('step_of', args: {'current': _currentPage + 1, 'total': 2}),
                    style: const TextStyle(
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
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
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
                 // Logic kept simple
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
              onChanged: (value) {
                if (!value.startsWith('+977')) {
                  _phoneController.value = TextEditingValue(
                    text: '+977' + value.replaceAll('+977', ''),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                }
              },
              validator: (v) {
                if (v == null || v.isEmpty) return translate('phone_required');
                if (!v.startsWith('+977')) return 'Must start with +977'; // Could translate this too
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Location Field with Autocomplete
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: null,
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
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _ageController,
              label: translate('age'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return translate('age_required');
                final age = int.tryParse(v);
                if (age == null) return translate('valid_age_required');
                if (age < 18 || age > 75) {
                  return 'Age must be between 18 and 75';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Text(translate('gender'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(translate('male')),
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(translate('female')),
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            RadioListTile<String>(
              title: Text(translate('other')),
              value: 'Other',
              groupValue: _gender,
              onChanged: (value) => setState(() => _gender = value),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            _buildTextFormField(
              controller: _hospitalController,
              label: translate('hospital_name'),
              validator: (v) => v!.isEmpty ? translate('hospital_required') : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: Text(
                '${translate("next")}: ${translate("blood_group")}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    text: translate('already_have_account') + ' ',
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: translate('login'),
                        style: const TextStyle(
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
              '${translate("blood_group")} & ${translate("security")}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _bloodGroup,
              decoration: InputDecoration(
                labelText: translate('required_blood_group'),
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
            // "Mark as Emergency" switch removed as requested
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
                child: Text('${translate("already_have_account")} ${translate("login")}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
