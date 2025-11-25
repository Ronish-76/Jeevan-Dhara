import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class HospitalEmergencyRequestPage extends StatefulWidget {
  const HospitalEmergencyRequestPage({super.key});

  @override
  State<HospitalEmergencyRequestPage> createState() => _HospitalEmergencyRequestPageState();
}

class _HospitalEmergencyRequestPageState extends State<HospitalEmergencyRequestPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  final _formKey = GlobalKey<FormState>();
  final _situationController = TextEditingController();
  final _unitsController = TextEditingController();
  String? _selectedBloodGroup;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _situationController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _sendEmergencyAlert() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) throw Exception('User not logged in');

      final requestData = {
        'bloodGroup': _selectedBloodGroup,
        'unitsRequired': int.parse(_unitsController.text),
        'urgency': 'critical',
        'requestedFrom': 'donor', // Default for emergency broadcast
        'notifyViaEmergency': true,
        'notes': _situationController.text.trim(),
        // Auto-filled fields are part of the user profile which backend already knows via hospital ID, 
        // but we send them if needed or just rely on backend to look up hospital.
        // Backend schema for HospitalBloodRequest doesn't have specific 'deliveryLocation' field separate from hospital location 
        // unless we put it in notes or additionalDetails. 
        // We'll put the specific contact person/phone in notes if they differ, but here they match user profile.
      };

      await ApiService().createHospitalBloodRequest(user.id!, requestData);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🚨 Alert Sent'),
          content: const Text('Emergency broadcast has been sent to all nearby donors.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send alert: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final location = user?.hospitalLocation ?? user?.location ?? 'Unknown Location';
    final contactPerson = user?.contactPerson ?? user?.fullName ?? 'Emergency Dept.';
    final phone = user?.hospitalPhone ?? user?.phone ?? 'Unknown';

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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFB71C1C)))
        : SingleChildScrollView(
        child: Column(
          children: [
            _buildUrgencyBanner(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildGuidelinesSection(),
                    const SizedBox(height: 24),
                    _buildBloodGroupDropdown(),
                    const SizedBox(height: 20),
                    _buildTextField('Units Needed *', 'Enter number of units', controller: _unitsController, isNumber: true),
                    const SizedBox(height: 20),
                    _buildReadOnlyField('Delivery Location *', location),
                    const SizedBox(height: 20),
                    _buildReadOnlyField('Contact Person *', contactPerson),
                    const SizedBox(height: 20),
                    _buildReadOnlyField('Contact Phone *', phone),
                    const SizedBox(height: 20),
                    _buildTextField('Situation Details', 'e.g., Cardiac surgery, Accident victim', controller: _situationController, maxLines: 3, isRequired: false),
                  ],
                ),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
          const Text('Emergency Guidelines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F))),
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

  Widget _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((bg) => 
        DropdownMenuItem(value: bg, child: Text(bg))
      ).toList(),
      onChanged: (val) => setState(() => _selectedBloodGroup = val),
      decoration: _inputDecoration('Blood Group *'),
      validator: (val) => val == null ? 'Required' : null,
    );
  }

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: _inputDecoration(label, hint: hint),
      validator: (val) {
        if (!isRequired) return null;
        if (val == null || val.isEmpty) return 'Required';
        return null;
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: _inputDecoration(label).copyWith(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
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

  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1.02).animate(_pulseController),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendEmergencyAlert,
              icon: const Icon(Icons.crisis_alert, color: Colors.white),
              label: const Text('SEND URGENT ALERT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
                disabledBackgroundColor: const Color(0xFFB71C1C).withOpacity(0.6),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Alert will be sent to matching donors within a 10 km radius.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
