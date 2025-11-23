import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/blood_request_viewmodel.dart';

class PostBloodRequestScreen extends StatefulWidget {
  const PostBloodRequestScreen({super.key});

  @override
  State<PostBloodRequestScreen> createState() => _PostBloodRequestScreenState();
}

class _PostBloodRequestScreenState extends State<PostBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _contactController = TextEditingController();
  final _detailsController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');

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
  String? _selectedBloodGroup;
  bool _notifyViaEmergency = true;
  bool _submitting = false;

  @override
  void dispose() {
    _patientNameController.dispose();
    _hospitalController.dispose();
    _contactController.dispose();
    _detailsController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BloodRequestViewModel>();

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
      body: AbsorbPointer(
        absorbing: _submitting || provider.isLoading,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(
                      controller: _patientNameController,
                      label: 'Patient Name',
                      hint: "Enter patient's full name",
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _hospitalController,
                      label: 'Hospital Name',
                      hint: 'Enter hospital or clinic name',
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _contactController,
                      label: 'Contact Number',
                      hint: 'Enter contact number',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.length < 5
                          ? 'Provide valid contact'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _unitsController,
                      label: 'Units Needed',
                      hint: 'Enter units (1-10)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final units = int.tryParse(value ?? '');
                        if (units == null || units < 1 || units > 10) {
                          return 'Enter 1-10 units';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFormField(
                      controller: _detailsController,
                      label: 'Additional Details',
                      hint: 'Add urgency, notes, etc.',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    _buildPrivacyToggle(),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                    const SizedBox(height: 30),
                    _buildNearestBanksSection(),
                  ],
                ),
              ),
            ),
            if (_submitting || provider.isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
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
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
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
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blood Group Required',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          hint: const Text('Select blood group'),
          validator: (value) => value == null ? 'Select blood group' : null,
          isExpanded: true,
          items: _bloodGroups
              .map(
                (group) => DropdownMenuItem(value: group, child: Text(group)),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedBloodGroup = value),
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
            color: Colors.black.withValues(alpha: 0.05),
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
                  'Notify via Emergency',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Send alerts to nearby donors anonymously',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _notifyViaEmergency,
            onChanged: (value) => setState(() => _notifyViaEmergency = value),
            activeTrackColor: const Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Submit Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNearestBanksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearest Blood Banks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tip: Contact blood banks directly for immediate availability.',
          style: TextStyle(color: Color(0xFF666666), fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildBankCard(
          'Central Blood Bank',
          'Kathmandu - 2.5 km',
          '+977-14225544',
        ),
        const SizedBox(height: 12),
        _buildBankCard(
          'Red Cross Blood Bank',
          'Lalitpur - 4.1 km',
          '+977-15549090',
        ),
        const SizedBox(height: 12),
        _buildBankCard(
          'Himalayan Blood Bank',
          'Bhaktapur - 7.8 km',
          '+977-16610555',
        ),
      ],
    );
  }

  Widget _buildBankCard(String name, String location, String phone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.home_work_outlined,
            color: Color(0xFFD32F2F),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.call_outlined,
                      size: 14,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) return;

    setState(() => _submitting = true);
    try {
      final position = await _determinePosition();
      if (!mounted) return;
      await context.read<BloodRequestViewModel>().submitRequest(
        requesterRole: 'patient',
        requesterName: _patientNameController.text.trim(),
        requesterContact: _contactController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        units: int.parse(_unitsController.text.trim()),
        lat: position.latitude,
        lng: position.longitude,
        notes: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted Successfully')),
      );
      _formKey.currentState?.reset();
      _selectedBloodGroup = null;
      _detailsController.clear();
      _unitsController.text = '1';
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Enable location services to continue.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required.');
    }
    return Geolocator.getCurrentPosition();
  }
}
