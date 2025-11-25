import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class HospitalPostBloodRequestPage extends StatefulWidget {
  const HospitalPostBloodRequestPage({super.key});

  @override
  State<HospitalPostBloodRequestPage> createState() => _HospitalPostBloodRequestPageState();
}

class _HospitalPostBloodRequestPageState extends State<HospitalPostBloodRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  String? _selectedBloodGroup;
  String _selectedUrgency = 'medium';
  String _requestedFrom = 'donor'; // Default to donor
  int _requiredUnits = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a blood group')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        throw Exception('User not logged in');
      }

      final requestData = {
        // 'patientName' removed as it's optional for hospitals
        'bloodGroup': _selectedBloodGroup,
        'unitsRequired': _requiredUnits,
        'urgency': _selectedUrgency,
        'requestedFrom': _requestedFrom,
        'notes': _notesController.text.trim(),
      };

      await ApiService().createHospitalBloodRequest(user.id!, requestData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blood request posted successfully')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post request: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final hospitalName = user?.hospital ?? user?.fullName ?? 'Hospital Name';
    final location = user?.hospitalLocation ?? user?.location ?? 'Unknown Location';
    final contact = user?.hospitalPhone ?? user?.phone ?? 'Unknown Number';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Post Blood Request'),
            Text('Notify nearby donors and blood banks', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuidelinesBanner(),
                const SizedBox(height: 24),
                // Patient Name Field Removed
                _buildDropdownField('Blood Group *', 'Select blood group', ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'], (val) => setState(() => _selectedBloodGroup = val)),
                const SizedBox(height: 20),
                _buildUnitsField(),
                const SizedBox(height: 20),
                _buildUrgencySelector(),
                const SizedBox(height: 20),
                _buildRequestSourceSelector(),
                const SizedBox(height: 20),
                _buildPrefilledField('Hospital Location *', location),
                const SizedBox(height: 20),
                _buildPrefilledField('Contact Number', contact),
                const SizedBox(height: 20),
                _buildNotesField(),
                const SizedBox(height: 30),
              ],
            ),
          ),
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildGuidelinesBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF2196F3)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fill in the details below to notify nearby donors and blood banks about your requirement.',
              style: TextStyle(fontSize: 12, color: Color(0xFF1E88E5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          hint: Text(hint),
          isExpanded: true,
          decoration: _inputDecoration(),
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildUnitsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Required Units *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: TextEditingController(text: _requiredUnits.toString()),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: _inputDecoration(),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 12),
            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => _requiredUnits = _requiredUnits > 1 ? _requiredUnits - 1 : 1)),
            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _requiredUnits++)),
          ],
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    final urgencies = {'Normal': 'low', 'Medium': 'medium', 'Urgent': 'high', 'Critical': 'critical'};
    final urgencyColors = {'low': Colors.blue, 'medium': Colors.teal, 'high': Colors.orange, 'critical': Colors.red};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Urgency Level *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView( 
            scrollDirection: Axis.horizontal,
            children: urgencies.entries.map((entry) {
              final label = entry.key;
              final value = entry.value;
              final isSelected = _selectedUrgency == value;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _selectedUrgency = value),
                  selectedColor: urgencyColors[value],
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

   Widget _buildRequestSourceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Request From *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Donors'),
                value: 'donor',
                groupValue: _requestedFrom,
                onChanged: (val) => setState(() => _requestedFrom = val!),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFD32F2F),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Blood Bank'),
                value: 'blood_bank',
                groupValue: _requestedFrom,
                onChanged: (val) => setState(() => _requestedFrom = val!),
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrefilledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: TextEditingController(text: value), // Use controller to show text
          readOnly: true,
          decoration: _inputDecoration().copyWith(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            suffixIcon: const Icon(Icons.check_circle, color: Colors.green),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: _inputDecoration().copyWith(hintText: 'Optional: Provide context to help donors understand the urgency'),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            disabledBackgroundColor: const Color(0xFFD32F2F).withOpacity(0.6),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Submit Blood Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5)),
    );
  }
}
