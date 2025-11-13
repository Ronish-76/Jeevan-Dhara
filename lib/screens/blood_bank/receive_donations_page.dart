import 'package:flutter/material.dart';

class ReceiveDonationsPage extends StatefulWidget {
  const ReceiveDonationsPage({super.key});

  @override
  State<ReceiveDonationsPage> createState() => _ReceiveDonationsPageState();
}

class _ReceiveDonationsPageState extends State<ReceiveDonationsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receive Donations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Register new blood donation', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickEntryCard(),
              const SizedBox(height: 24),
              _buildDonorInfoForm(),
              const SizedBox(height: 24),
              _buildDonationDetailsForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildQuickEntryCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text('Scan Donor QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 8),
          const Text('OR', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search by Donor ID or Name',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Color(0xFFF8F9FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorInfoForm(){
    return _buildFormSection(
      title: 'Donor Information',
      children: [
         _buildTextFormField(label: 'Donor Name *'),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Contact Number', keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Address'),
      ]
    );
  }

   Widget _buildDonationDetailsForm(){
    return _buildFormSection(
      title: 'Donation Details',
      children: [
         _buildDropdownField(label: 'Blood Group *', items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Units Donated *', keyboardType: TextInputType.number, hint: 'Typically 1 unit = 450ml'),
        const SizedBox(height: 12),
        _buildDatePickerField(context, label: 'Donation Date *'),
      ]
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Divider(height: 24), ...children]),
        );
  }

  Widget _buildTextFormField({required String label, String? hint, TextInputType? keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {},
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildDatePickerField(BuildContext context, {required String label}) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () async {
        await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
      },
      validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('* Required fields', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process data
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      );
  }
}
