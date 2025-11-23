import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';

class ReceiveDonationsPage extends StatefulWidget {
  const ReceiveDonationsPage({super.key});

  @override
  State<ReceiveDonationsPage> createState() => _ReceiveDonationsPageState();
}

class _ReceiveDonationsPageState extends State<ReceiveDonationsPage> {
  final _formKey = GlobalKey<FormState>();
  final _donorNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _searchController = TextEditingController();
  String? _selectedBloodGroup;
  DateTime? _donationDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _donationDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _donorNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _unitsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final inventoryViewModel = context.read<InventoryViewModel>();
    if (inventoryViewModel.nearbyFacilities.isEmpty) {
      await inventoryViewModel.fetchNearbyFacilities(role: UserRole.bloodBank);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a blood group')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Call API to record donation and update inventory
      final inventoryViewModel = context.read<InventoryViewModel>();
      final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
          ? inventoryViewModel.nearbyFacilities.first
          : null;

      if (facility != null) {
        // In a real app, this would call an API to:
        // 1. Create a donation record
        // 2. Update the blood bank inventory
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _formKey.currentState!.reset();
          _donorNameController.clear();
          _contactController.clear();
          _addressController.clear();
          _unitsController.text = '1';
          _selectedBloodGroup = null;
          _donationDate = DateTime.now();
          await inventoryViewModel.fetchNearbyFacilities(
            role: UserRole.bloodBank,
            forceRefresh: true,
          );
        }
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
            Text(
              'Receive Donations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Register new blood donation',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('OR', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search by Donor ID or Name',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorInfoForm() {
    return _buildFormSection(
      title: 'Donor Information',
      children: [
        _buildTextFormField(
          controller: _donorNameController,
          label: 'Donor Name *',
        ),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _contactController,
          label: 'Contact Number',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _addressController,
          label: 'Address',
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildDonationDetailsForm() {
    return _buildFormSection(
      title: 'Donation Details',
      children: [
        _buildBloodGroupDropdown(),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _unitsController,
          label: 'Units Donated *',
          keyboardType: TextInputType.number,
          hint: 'Typically 1 unit = 450ml',
        ),
        const SizedBox(height: 12),
        _buildDatePickerField(context, label: 'Donation Date *'),
      ],
    );
  }

  Widget _buildBloodGroupDropdown() {
    final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    return DropdownButtonFormField<String>(
      value: _selectedBloodGroup,
      decoration: const InputDecoration(
        labelText: 'Blood Group *',
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: bloodGroups
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) => setState(() => _selectedBloodGroup = value),
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
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
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDatePickerField(BuildContext context, {required String label}) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _donationDate != null
            ? '${_donationDate!.day}/${_donationDate!.month}/${_donationDate!.year}'
            : '',
      ),
      decoration: const InputDecoration(
        labelText: 'Donation Date *',
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _donationDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() => _donationDate = picked);
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '* Required fields',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Entry',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
