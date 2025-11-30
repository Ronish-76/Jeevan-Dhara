import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class RequesterPostBloodRequestScreen extends StatefulWidget {
  const RequesterPostBloodRequestScreen({super.key});

  @override
  State<RequesterPostBloodRequestScreen> createState() =>
      _RequesterPostBloodRequestScreenState();
}

class _RequesterPostBloodRequestScreenState
    extends State<RequesterPostBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _detailsController = TextEditingController();

  String? _selectedBloodGroup;
  bool _notifyViaEmergency = true;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPrerequisitesAndAutofill();
    });
  }

  void _checkPrerequisitesAndAutofill() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (user == null) return;

    // Check prerequisites
    if (user.hospital == null ||
        user.hospital!.isEmpty ||
        user.hospitalLocation == null ||
        user.hospitalLocation!.isEmpty ||
        user.hospitalPhone == null ||
        user.hospitalPhone!.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Hospital Details Missing'),
          content: const Text(
            'You must set your Hospital Name, Location, and Phone in your profile before posting a blood request.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
      return;
    }

    // Auto-fill
    setState(() {
      _hospitalNameController.text = user.hospital ?? '';
      _locationController.text = user.hospitalLocation ?? '';
      _phoneController.text = user.hospitalPhone ?? '';
      _patientNameController.text = user.fullName ?? '';
      _patientPhoneController.text = user.phone ?? '';
      
      // Only auto-fill if the blood group is valid and in the list
      if (user.bloodGroup != null && _bloodGroups.contains(user.bloodGroup)) {
        _selectedBloodGroup = user.bloodGroup;
      }
    });
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _patientPhoneController.dispose();
    _unitsController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final requestData = {
        'patientName': _patientNameController.text,
        'patientPhone': _patientPhoneController.text,
        'bloodGroup': _selectedBloodGroup,
        'hospitalName': _hospitalNameController.text,
        'location': _locationController.text,
        'contactNumber': _phoneController.text,
        'units': int.tryParse(_unitsController.text) ?? 1,
        'additionalDetails': _detailsController.text,
        'notifyViaEmergency': _notifyViaEmergency,
        'requesterId': user?.id,
      };

      await ApiService().createBloodRequest(requestData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blood request posted successfully!')),
      );
      Navigator.pop(context); // Go back after success
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Failed to post request';
      if (e.toString().contains('Bad Request:')) {
        // Extract the message from the exception string if possible
        // The exception format is usually "Exception: Bad Request: {message: ...}"
        try {
          final errorPart = e.toString().split('Bad Request:')[1].trim();
          // Simple check if it contains our specific error message
          if (errorPart.contains('active blood request')) {
            errorMessage =
                'You already have an active blood request. Please cancel or complete it first.';
          } else {
            errorMessage = errorPart;
          }
        } catch (_) {
          errorMessage = e.toString();
        }
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Post Blood Request'),
            Text(
              'Help save a life today',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(
                      controller: _patientNameController,
                      label: 'Patient Name',
                      hint: "Enter patient's full name",
                      readOnly: true,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _patientPhoneController,
                      label: 'Patient Phone',
                      hint: "Enter patient's phone number",
                      readOnly: true,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Blood Group Required',
                      hint: 'Select blood group',
                      value: _selectedBloodGroup,
                      items: _bloodGroups,
                      onChangedCallback: (value) {
                        setState(() {
                          _selectedBloodGroup = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _hospitalNameController,
                      label: 'Hospital Name',
                      hint: 'Enter hospital or clinic name',
                      readOnly: true, // Auto-filled and read-only
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'Hospital Location',
                      readOnly: true, // Auto-filled and read-only
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Contact Number',
                      hint: 'Enter contact number',
                      keyboardType: TextInputType.phone,
                      readOnly: true, // Auto-filled and read-only
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _unitsController,
                      label: 'Blood Units Required',
                      hint: 'Enter number of units (e.g. 1)',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null || int.parse(v) < 1)
                          return 'Invalid units';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _detailsController,
                      label: 'Additional Details',
                      hint:
                          'Add any additional information (units needed, urgency details, etc.)',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    _buildPrivacyToggle(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: readOnly ? Colors.grey[200] : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD32F2F),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    String? value,
    required List<String> items,
    void Function(String?)? onChangedCallback,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(
                color: Color(0xFFD32F2F),
                width: 1.5,
              ),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChangedCallback,
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Notify via Emergency",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  "Privacy notification to all nearby donors",
                  style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _notifyViaEmergency,
            onChanged: (value) {
              setState(() {
                _notifyViaEmergency = value;
              });
            },
            activeColor: const Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          'Submit Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
