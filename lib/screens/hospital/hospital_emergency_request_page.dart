import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class HospitalEmergencyRequestPage extends StatefulWidget {
  const HospitalEmergencyRequestPage({super.key});

  @override
  State<HospitalEmergencyRequestPage> createState() =>
      _HospitalEmergencyRequestPageState();
}

class _HospitalEmergencyRequestPageState
    extends State<HospitalEmergencyRequestPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final _formKey = GlobalKey<FormState>();
  final _bloodGroupController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _situationController = TextEditingController();
  String? _selectedBloodGroup;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFacilityData());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bloodGroupController.dispose();
    _unitsController.dispose();
    _locationController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _situationController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilityData() async {
    final inventoryViewModel = context.read<InventoryViewModel>();
    if (inventoryViewModel.nearbyFacilities.isEmpty) {
      await inventoryViewModel.fetchNearbyFacilities(
        role: UserRole.hospital,
      );
    }
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    if (facility != null && mounted) {
      setState(() {
        _locationController.text = facility.displayAddress;
        _contactPhoneController.text = facility.contactNumber ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Emergency Request'),
        actions: [
          FadeTransition(
            opacity: _pulseController,
            child: const Icon(Icons.crisis_alert_sharp, size: 28),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUrgencyBanner(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildGuidelinesSection(),
                  const SizedBox(height: 24),
                  _buildEmergencyForm(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionSection(),
    );
  }

  Widget _buildUrgencyBanner() {
    return Container(
      color: const Color(0xFFB71C1C),
      padding: const EdgeInsets.all(12),
      child: FadeTransition(
        opacity: _pulseController,
        child: const Center(
          child: Text(
            'IMMEDIATE BLOOD REQUIREMENT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelinesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD32F2F).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Guidelines',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(height: 8),
          _buildGuidelineItem('Request bypasses normal approval.'),
          _buildGuidelineItem('Alert sent to all donors within 10 km.'),
          _buildGuidelineItem('SMS + Push notifications are enabled.'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildEmergencyForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildBloodGroupDropdown(),
          const SizedBox(height: 20),
          _buildUnitsField(),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _locationController,
            label: 'Delivery Location *',
            hint: 'Hospital location',
            isRequired: true,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _contactPersonController,
            label: 'Contact Person *',
            hint: 'Dr. Sharma - Emergency Dept.',
            isRequired: true,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _contactPhoneController,
            label: 'Contact Phone *',
            hint: '+977 98XXXXXXXX',
            isRequired: true,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _situationController,
            label: 'Situation Details',
            hint: 'e.g., Cardiac surgery, Accident victim',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupDropdown() {
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Blood Group *',
          style: TextStyle(
            color: const Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedBloodGroup,
          decoration: _inputDecoration(),
          items: bloodGroups
              .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
              .toList(),
          onChanged: (value) => setState(() => _selectedBloodGroup = value),
          validator: (value) =>
              value == null ? 'Please select a blood group' : null,
        ),
      ],
    );
  }

  Widget _buildUnitsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Units Needed *',
          style: TextStyle(
            color: const Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _unitsController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter units needed';
            }
            final units = int.tryParse(value);
            if (units == null || units < 1) {
              return 'Units must be at least 1';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isRequired ? const Color(0xFFB71C1C) : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
        helperText: isRequired ? 'This field is required' : 'Optional',
        helperStyle: TextStyle(
          color: isRequired ? const Color(0xFFB71C1C) : Colors.grey,
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF5F5F5) : const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isRequired
                ? const Color(0xFFD32F2F).withOpacity(0.5)
                : Colors.grey.shade300,
          ),
        ),
      ),
      validator: isRequired
          ? (value) =>
                value == null || value.isEmpty ? 'This field is required' : null
          : null,
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    final inventoryViewModel = context.read<InventoryViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    if (facility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to determine facility location')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Emergency Request'),
        content: Text(
          'Send urgent alert for ${_unitsController.text} units of $_selectedBloodGroup?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      final bloodRequestViewModel = context.read<BloodRequestViewModel>();
      final notes =
          'EMERGENCY: ${_situationController.text}\n'
          'Contact: ${_contactPersonController.text}\n'
          'Location: ${_locationController.text}';

      await bloodRequestViewModel.submitRequest(
        requesterRole: 'hospital',
        requesterName: _contactPersonController.text,
        requesterContact: _contactPhoneController.text,
        bloodGroup: _selectedBloodGroup!,
        units: int.parse(_unitsController.text),
        lat: facility.latitude,
        lng: facility.longitude,
        notes: notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(
              begin: 0.98,
              end: 1.02,
            ).animate(_pulseController),
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.crisis_alert, color: Colors.white),
              label: Text(_isSubmitting ? 'SENDING...' : 'SEND URGENT ALERT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Alert will be sent to matching donors within a 10 km radius.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
