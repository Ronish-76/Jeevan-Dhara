import 'package:flutter/material.dart';

class PostBloodRequestScreen extends StatefulWidget {
  const PostBloodRequestScreen({super.key});

  @override
  State<PostBloodRequestScreen> createState() => _PostBloodRequestScreenState();
}

class _PostBloodRequestScreenState extends State<PostBloodRequestScreen> {
  String? _selectedBloodGroup;
  String? _selectedCity;
  bool _notifyViaEmergency = true;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  final List<String> _cities = ['Kathmandu', 'Pokhara', 'Lalitpur', 'Bhaktapur', 'Biratnagar'];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormField(label: 'Patient Name', hint: "Enter patient's full name"),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'Blood Group Required',
              hint: 'Select blood group',
              value: _selectedBloodGroup,
              items: _bloodGroups,
              onChanged: (value) {
                setState(() {
                  _selectedBloodGroup = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildFormField(label: 'Hospital Name', hint: 'Enter hospital or clinic name'),
            const SizedBox(height: 12),
            _buildDropdownField(
              label: 'City',
              hint: 'Select city',
              value: _selectedCity,
              items: _cities,
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildFormField(label: 'Contact Number', hint: 'Enter contact number', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildFormField(label: 'Additional Details', hint: 'Add any additional information (units needed, urgency details, etc.)', maxLines: 4),
            const SizedBox(height: 20),
            _buildPrivacyToggle(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 30),
            _buildNearestBanksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({required String label, required String hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String hint, String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
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
                Text("Notify via Emergency", style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text("Privacy notification to all nearby donors", style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildNearestBanksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Nearest Blood Banks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          "Tip: Contact blood banks directly for immediate availability. Your request will also be visible to registered donors in your area.",
          style: TextStyle(color: Color(0xFF666666), fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildBankCard("Central Blood Bank", "Kathmandu - 2.5 km", "+977-14225544"),
        const SizedBox(height: 12),
        _buildBankCard("Red Cross Blood Bank", "Lalitpur - 4.1 km", "+977-15549090"),
         const SizedBox(height: 12),
        _buildBankCard("Himalayan Blood Bank", "Bhaktapur - 7.8 km", "+977-16610555"),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.home_work_outlined, color: Color(0xFFD32F2F), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                  ],
                ),
                 const SizedBox(height: 4),
                Row(
                  children: [
                     const Icon(Icons.call_outlined, size: 14, color: Color(0xFF666666)),
                    const SizedBox(width: 4),
                    Text(phone, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
