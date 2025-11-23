import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class DistributeBloodPage extends StatefulWidget {
  const DistributeBloodPage({super.key});

  @override
  State<DistributeBloodPage> createState() => _DistributeBloodPageState();
}

class _DistributeBloodPageState extends State<DistributeBloodPage> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  final _courierController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  String? _selectedHospital;
  String? _selectedBloodType;
  DateTime? _dispatchDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dispatchDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _courierController.dispose();
    _vehicleController.dispose();
    _driverController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final bloodRequestViewModel = context.read<BloodRequestViewModel>();
    final inventoryViewModel = context.read<InventoryViewModel>();
    await Future.wait([
      bloodRequestViewModel.fetchActiveRequests(forceRefresh: true),
      inventoryViewModel.fetchNearbyFacilities(role: UserRole.bloodBank),
    ]);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHospital == null || _selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Call API to record distribution and update inventory
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Blood distribution recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _unitsController.clear();
        _courierController.clear();
        _vehicleController.clear();
        _driverController.clear();
        _selectedHospital = null;
        _selectedBloodType = null;
        _dispatchDate = DateTime.now();
        await context.read<InventoryViewModel>().fetchNearbyFacilities(
          role: UserRole.bloodBank,
          forceRefresh: true,
        );
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
              'Distribute Blood',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Send blood to hospitals',
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
            children: [
              _buildStatsOverview(),
              const SizedBox(height: 20),
              _buildDispatchForm(),
              const SizedBox(height: 20),
              _buildCourierForm(),
              const SizedBox(height: 20),
              _buildWeeklySummary(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStatsOverview() {
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    final inventory = facility?.inventory ?? {};
    final totalUnits = inventory.values.fold<int>(
      0,
      (sum, units) => sum + units,
    );
    final emergencyRequests = bloodRequestViewModel.requests
        .where((r) => r.status == 'pending')
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: totalUnits.toString(), label: 'Total Units'),
          _StatItem(
            value: bloodRequestViewModel.requests.length.toString(),
            label: 'Requests',
          ),
          _StatItem(
            value: emergencyRequests.toString(),
            label: 'Emergency',
            isEmergency: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDispatchForm() {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final hospitals = bloodRequestViewModel.requests
        .map((r) => r.requesterName)
        .toSet()
        .toList();

    return _buildFormSection(
      title: 'Dispatch Information',
      children: [
        _buildHospitalDropdown(hospitals),
        const SizedBox(height: 12),
        _buildBloodTypeDropdown(),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _unitsController,
          label: 'Units Dispatched *',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _buildDatePickerField(context, label: 'Dispatch Date *'),
      ],
    );
  }

  Widget _buildHospitalDropdown(List<String> hospitals) {
    return DropdownButtonFormField<String>(
      value: _selectedHospital,
      decoration: const InputDecoration(
        labelText: 'Hospital Name *',
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
      items: hospitals.isEmpty
          ? [
              'Bir Hospital',
              'Patan Hospital',
              'Civil Hospital',
            ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList()
          : hospitals
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
      onChanged: (value) => setState(() => _selectedHospital = value),
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildBloodTypeDropdown() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: const InputDecoration(
        labelText: 'Blood Type *',
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
      items: bloodTypes
          .map((bt) => DropdownMenuItem(value: bt, child: Text(bt)))
          .toList(),
      onChanged: (value) => setState(() => _selectedBloodType = value),
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildCourierForm() {
    return _buildFormSection(
      title: 'Courier/Transport Information',
      children: [
        _buildTextFormField(
          controller: _courierController,
          label: 'Courier Name *',
        ),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _vehicleController,
          label: 'Vehicle Number',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        _buildTextFormField(
          controller: _driverController,
          label: 'Driver Contact',
          keyboardType: TextInputType.phone,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildWeeklySummary() {
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    final inventory = facility?.inventory ?? {};

    if (inventory.isEmpty) {
      return const SizedBox.shrink();
    }

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
          const Text(
            'Current Inventory',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final entry = inventory.entries.elementAt(index);
              return _BloodTypeCell(bloodType: entry.key, units: entry.value);
            },
          ),
        ],
      ),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: const InputDecoration(
        labelText: 'Label',
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ).copyWith(labelText: label),
      validator: isRequired
          ? (value) => (value == null || value.isEmpty)
                ? 'This field is required'
                : null
          : null,
    );
  }

  Widget _buildDatePickerField(BuildContext context, {required String label}) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _dispatchDate != null
            ? '${_dispatchDate!.day}/${_dispatchDate!.month}/${_dispatchDate!.year}'
            : '',
      ),
      decoration: const InputDecoration(
        labelText: 'Dispatch Date *',
        filled: true,
        fillColor: Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dispatchDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _dispatchDate = picked);
        }
      },
      validator: (value) =>
          (value == null || value.isEmpty) ? 'This field is required' : null,
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
        children: [
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
                      'Confirm Dispatch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '* Required fields',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final bool isEmergency;
  const _StatItem({
    required this.value,
    required this.label,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isEmergency
        ? const Color(0xFF2196F3)
        : const Color(0xFF333333);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}

class _BloodTypeCell extends StatelessWidget {
  final String bloodType;
  final int units;
  const _BloodTypeCell({required this.bloodType, required this.units});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            bloodType,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$units units',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
