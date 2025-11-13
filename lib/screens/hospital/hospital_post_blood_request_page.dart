import 'package:flutter/material.dart';

class HospitalPostBloodRequestPage extends StatefulWidget {
  const HospitalPostBloodRequestPage({super.key});

  @override
  State<HospitalPostBloodRequestPage> createState() => _HospitalPostBloodRequestPageState();
}

class _HospitalPostBloodRequestPageState extends State<HospitalPostBloodRequestPage> {
  String? _selectedBloodGroup;
  String? _selectedUrgency;
  int _requiredUnits = 1;

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuidelinesBanner(),
            const SizedBox(height: 24),
            _buildDropdownField('Blood Group *', 'Select blood group', ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'], (val) => setState(() => _selectedBloodGroup = val)),
            const SizedBox(height: 20),
            _buildUnitsField(),
            const SizedBox(height: 20),
            _buildUrgencySelector(),
            const SizedBox(height: 20),
            _buildDropdownField('Hospital Department *', 'Select department', ['Emergency', 'Surgery', 'ICU', 'Maternity'], (val) {}),
            const SizedBox(height: 20),
            _buildPrefilledField('Hospital Location *', 'Bir Hospital, Kathmandu, Nepal'),
            const SizedBox(height: 20),
            _buildPrefilledField('Contact Number', '+977 1-4221119'),
            const SizedBox(height: 20),
            _buildNotesField(),
            const SizedBox(height: 30),
          ],
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
    final urgencies = {'Normal': Colors.blue, 'Urgent': Colors.orange, 'Critical': Colors.red};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Urgency Level *', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView( 
            scrollDirection: Axis.horizontal,
            children: urgencies.keys.map((urgency) {
              final isSelected = _selectedUrgency == urgency;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(urgency),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _selectedUrgency = selected ? urgency : null),
                  selectedColor: urgencies[urgency],
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

  Widget _buildPrefilledField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Submit Blood Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
