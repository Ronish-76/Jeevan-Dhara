import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

class ReceiveDonationsPage extends StatefulWidget {
  const ReceiveDonationsPage({super.key});

  @override
  State<ReceiveDonationsPage> createState() => _ReceiveDonationsPageState();
}

class _ReceiveDonationsPageState extends State<ReceiveDonationsPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _unitsController = TextEditingController();
  final _dateController = TextEditingController();
  
  String? _selectedBloodGroup;
  String? _selectedDonorId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _unitsController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a blood group')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) throw Exception('User not logged in');

      final data = {
        'donorId': _selectedDonorId,
        'donorName': _nameController.text,
        'contactNumber': _contactController.text,
        'address': _addressController.text,
        'bloodGroup': _selectedBloodGroup,
        'units': int.tryParse(_unitsController.text) ?? 1,
        'donationDate': _dateController.text.isEmpty 
            ? DateTime.now().toIso8601String() 
            : DateTime.parse(_dateController.text).toIso8601String(),
      };

      await ApiService().recordDonation(user.id!, data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation recorded and stock updated successfully')));
      
      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _contactController.clear();
      _addressController.clear();
      _unitsController.clear();
      _dateController.clear();
      setState(() {
        _selectedBloodGroup = null;
        _selectedDonorId = null;
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to record donation: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
        : SingleChildScrollView(
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
          // Removed scan QR button from here
          
          // Autocomplete Search
          LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  try {
                    final donors = await ApiService().searchDonors(textEditingValue.text);
                    return donors.cast<Map<String, dynamic>>();
                  } catch (e) {
                    debugPrint('Search error: $e');
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                },
                displayStringForOption: (Map<String, dynamic> option) => option['fullName'] ?? 'Unknown',
                onSelected: (Map<String, dynamic> selection) {
                  setState(() {
                    _selectedDonorId = selection['_id'];
                    _nameController.text = selection['fullName'] ?? '';
                    _contactController.text = selection['phone'] ?? '';
                    _addressController.text = selection['location'] ?? '';
                    _selectedBloodGroup = selection['bloodGroup']; // If blood group is fixed for donor
                    // Units and Date remain empty as requested
                  });
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onSubmitted: (value) => onFieldSubmitted(),
                    decoration: const InputDecoration(
                      hintText: 'Search by Donor ID or Name',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> option = options.elementAt(index);
                            return ListTile(
                              title: Text(option['fullName'] ?? 'Unknown'),
                              subtitle: Text('${option['bloodGroup'] ?? ''} • ${option['phone'] ?? ''}'),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildDonorInfoForm(){
    return _buildFormSection(
      title: 'Donor Information',
      children: [
         _buildTextFormField(controller: _nameController, label: 'Donor Name *'),
        const SizedBox(height: 12),
        _buildTextFormField(controller: _contactController, label: 'Contact Number', keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _buildTextFormField(controller: _addressController, label: 'Address'),
      ]
    );
  }

   Widget _buildDonationDetailsForm(){
    return _buildFormSection(
      title: 'Donation Details',
      children: [
         _buildDropdownField(
           label: 'Blood Group *', 
           items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
           value: _selectedBloodGroup,
           onChanged: (val) => setState(() => _selectedBloodGroup = val),
         ),
        const SizedBox(height: 12),
        _buildTextFormField(controller: _unitsController, label: 'Units Donated *', keyboardType: TextInputType.number, hint: 'Typically 1 unit = 450ml'),
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

  Widget _buildTextFormField({required String label, TextEditingController? controller, String? hint, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
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

  Widget _buildDropdownField({required String label, required List<String> items, String? value, ValueChanged<String?>? onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildDatePickerField(BuildContext context, {required String label}) {
    return TextFormField(
      controller: _dateController,
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
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          _dateController.text = DateFormat('yyyy-MM-dd').format(date);
        }
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
                onPressed: _isLoading ? null : _saveEntry,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  disabledBackgroundColor: const Color(0xFFD32F2F).withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      );
  }
}
