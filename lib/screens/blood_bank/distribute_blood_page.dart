import 'package:flutter/material.dart';

class DistributeBloodPage extends StatefulWidget {
  const DistributeBloodPage({super.key});

  @override
  State<DistributeBloodPage> createState() => _DistributeBloodPageState();
}

class _DistributeBloodPageState extends State<DistributeBloodPage> {
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
            Text('Distribute Blood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Send blood to hospitals', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '144', label: 'Total Units'),
          _StatItem(value: '12', label: 'Hospitals'),
          _StatItem(value: '5', label: 'Emergency', isEmergency: true),
        ],
      ),
    );
  }

  Widget _buildDispatchForm() {
    return _buildFormSection(
      title: 'Dispatch Information',
      children: [
        _buildDropdownField(label: 'Hospital Name *', items: ['Bir Hospital', 'Patan Hospital', 'Civil Hospital']),
        const SizedBox(height: 12),
        _buildDropdownField(label: 'Blood Type *', items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Units Dispatched *', keyboardType: TextInputType.number),
         const SizedBox(height: 12),
        _buildDatePickerField(context, label: 'Dispatch Date *'),
      ],
    );
  }

  Widget _buildCourierForm() {
    return _buildFormSection(
      title: 'Courier/Transport Information',
      children: [
        _buildTextFormField(label: 'Courier Name *'),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Vehicle Number', isRequired: false),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Driver Contact', keyboardType: TextInputType.phone, isRequired: false),
      ],
    );
  }
  
  Widget _buildWeeklySummary() {
    final summary = {'A+': 40, 'A-': 15, 'B+': 30, 'B-': 10, 'O+': 25, 'O-': 8, 'AB+': 12, 'AB-': 4};

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
          const Text("This Week's Distribution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Divider(height:24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: summary.length,
            itemBuilder: (context, index) {
              final group = summary.keys.elementAt(index);
              final units = summary.values.elementAt(index);
              return _BloodTypeCell(bloodType: group, units: units);
            },
          ),
        ],
      ),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const Divider(height: 24), ...children]),
    );
  }

  Widget _buildTextFormField({required String label, TextInputType? keyboardType, bool isRequired = true}) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8F9FA), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)),
      validator: isRequired ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null : null,
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8F9FA), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {},
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildDatePickerField(BuildContext context, {required String label}) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8F9FA), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none), suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () => showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100)),
      validator: (value) => (value == null || value.isEmpty) ? 'This field is required' : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => _formKey.currentState?.validate(),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Confirm Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('* Required fields', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final bool isEmergency;
  const _StatItem({required this.value, required this.label, this.isEmergency = false});

  @override
  Widget build(BuildContext context) {
    final color = isEmergency ? const Color(0xFF2196F3) : const Color(0xFF333333);
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
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
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(bloodType, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const SizedBox(height: 4),
          Text('$units units', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
