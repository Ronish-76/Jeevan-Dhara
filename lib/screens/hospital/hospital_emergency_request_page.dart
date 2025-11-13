import 'package:flutter/material.dart';

class HospitalEmergencyRequestPage extends StatefulWidget {
  const HospitalEmergencyRequestPage({super.key});

  @override
  State<HospitalEmergencyRequestPage> createState() => _HospitalEmergencyRequestPageState();
}

class _HospitalEmergencyRequestPageState extends State<HospitalEmergencyRequestPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;

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
    super.dispose();
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

  Widget _buildEmergencyForm() {
    return Column(
      children: [
        _buildFormField('Blood Group *', 'Select blood group', isRequired: true),
        const SizedBox(height: 20),
        _buildFormField('Units Needed *', 'Enter number of units', isRequired: true),
        const SizedBox(height: 20),
        _buildFormField('Delivery Location *', 'Bir Hospital - Emergency Ward', isRequired: true, prefilled: true),
        const SizedBox(height: 20),
        _buildFormField('Contact Person *', 'Dr. Sharma - Emergency Dept.', isRequired: true),
        const SizedBox(height: 20),
        _buildFormField('Contact Phone *', '+977 98XXXXXXXX', isRequired: true, prefilled: true),
        const SizedBox(height: 20),
        _buildFormField('Situation Details', 'e.g., Cardiac surgery, Accident victim', maxLines: 3),
      ],
    );
  }

  Widget _buildFormField(String label, String hint, {bool isRequired = false, bool prefilled = false, int maxLines = 1}) {
    return TextFormField(
      initialValue: prefilled ? hint : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: prefilled ? null : hint,
        labelStyle: TextStyle(color: isRequired ? const Color(0xFFB71C1C) : Colors.black54, fontWeight: FontWeight.bold),
        helperText: isRequired ? 'This field is required' : 'Optional',
        helperStyle: TextStyle(color: isRequired ? const Color(0xFFB71C1C) : Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF9F9F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isRequired ? const Color(0xFFD32F2F).withOpacity(0.5) : Colors.grey.shade300),
        ),
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
              onPressed: () {
                // TODO: Add confirmation dialog
              },
              icon: const Icon(Icons.crisis_alert, color: Colors.white),
              label: const Text('SEND URGENT ALERT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C),
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
