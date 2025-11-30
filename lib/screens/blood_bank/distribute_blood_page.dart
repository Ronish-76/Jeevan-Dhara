import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

class DistributeBloodPage extends StatefulWidget {
  final String? prefilledHospitalId;
  final String? prefilledHospitalName;
  final String? prefilledBloodGroup;
  final int? prefilledUnits;
  final String? requestId;

  const DistributeBloodPage({
    super.key,
    this.prefilledHospitalId,
    this.prefilledHospitalName,
    this.prefilledBloodGroup,
    this.prefilledUnits,
    this.requestId,
  });

  @override
  State<DistributeBloodPage> createState() => _DistributeBloodPageState();
}

class _DistributeBloodPageState extends State<DistributeBloodPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _unitsController;
  final _dateController = TextEditingController();
  final _courierController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _driverContactController = TextEditingController();
  final _hospitalController = TextEditingController();

  String? _selectedBloodType;
  String? _selectedHospitalId;
  String? _selectedHospitalName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedHospitalId = widget.prefilledHospitalId;
    _selectedHospitalName = widget.prefilledHospitalName;
    _selectedBloodType = widget.prefilledBloodGroup;
    _unitsController = TextEditingController(text: widget.prefilledUnits?.toString() ?? '');
    if (_selectedHospitalName != null) {
      _hospitalController.text = _selectedHospitalName!;
    }
  }
  
  @override
  void dispose() {
    _unitsController.dispose();
    _dateController.dispose();
    _courierController.dispose();
    _vehicleController.dispose();
    _driverContactController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _confirmDispatch() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedHospitalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a valid hospital from the list')));
      return;
    }
    if (_selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a blood type')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) throw Exception('User not logged in');

      final data = {
        'requestId': widget.requestId,
        'hospitalId': _selectedHospitalId,
        'hospitalName': _selectedHospitalName,
        'bloodGroup': _selectedBloodType,
        'units': int.tryParse(_unitsController.text) ?? 0,
        'dispatchDate': _dateController.text.isEmpty 
            ? DateTime.now().toIso8601String() 
            : DateTime.parse(_dateController.text).toIso8601String(),
        'courierName': _courierController.text,
        'vehicleNumber': _vehicleController.text,
        'driverContact': _driverContactController.text,
      };

      await ApiService().recordDistribution(user.id!, data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Blood dispatch confirmed and recorded successfully')));
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to record distribution: $e')));
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
            Text('Distribute Blood', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Send blood to hospitals', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
            children: [
              _buildDispatchForm(),
              const SizedBox(height: 20),
              _buildCourierForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDispatchForm() {
    return _buildFormSection(
      title: 'Dispatch Information',
      children: [
        // Autocomplete for Hospital Name
        LayoutBuilder(
          builder: (context, constraints) {
            return Autocomplete<Map<String, dynamic>>(
              initialValue: TextEditingValue(text: _selectedHospitalName ?? ''),
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Map<String, dynamic>>.empty();
                }
                try {
                  final hospitals = await ApiService().searchHospitals(textEditingValue.text);
                  return hospitals.cast<Map<String, dynamic>>();
                } catch (e) {
                  debugPrint('Search error: $e');
                  return const Iterable<Map<String, dynamic>>.empty();
                }
              },
              displayStringForOption: (Map<String, dynamic> option) => option['hospitalName'] ?? 'Unknown',
              onSelected: (Map<String, dynamic> selection) {
                setState(() {
                  _selectedHospitalId = selection['_id'];
                  _selectedHospitalName = selection['hospitalName'];
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                // Update controller if prefilled name is set but controller is empty (initial state)
                if (_selectedHospitalName != null && textEditingController.text.isEmpty) {
                   textEditingController.text = _selectedHospitalName!;
                }
                // Also update _selectedHospitalName if user types manually to allow filtering
                textEditingController.addListener(() {
                   _selectedHospitalName = textEditingController.text;
                });
                
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Name *',
                    filled: true,
                    fillColor: Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.search),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    // Allow loose text if ID is null (maybe for manual entry of unknown hospital?) 
                    // But keeping strict validation based on previous logic
                    if (_selectedHospitalId == null && val.isNotEmpty) {
                       // Relaxed validation: if text is there but no ID selected, warn user or try to find match
                       // For now, stick to requiring selection
                       // return 'Please select a valid hospital from list';
                    }
                    return null;
                  },
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
                            title: Text(option['hospitalName'] ?? 'Unknown'),
                            subtitle: Text(option['fullAddress'] ?? ''),
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
        const SizedBox(height: 12),
        _buildDropdownField(
          label: 'Blood Type *', 
          items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'],
          value: _selectedBloodType,
          onChanged: (val) => setState(() => _selectedBloodType = val),
        ),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Units Dispatched *', controller: _unitsController, keyboardType: TextInputType.number),
         const SizedBox(height: 12),
        _buildDatePickerField(context, label: 'Dispatch Date *'),
      ],
    );
  }

  Widget _buildCourierForm() {
    return _buildFormSection(
      title: 'Courier/Transport Information',
      children: [
        _buildTextFormField(label: 'Courier Name *', controller: _courierController),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Vehicle Number', controller: _vehicleController, isRequired: false),
        const SizedBox(height: 12),
        _buildTextFormField(label: 'Driver Contact', controller: _driverContactController, keyboardType: TextInputType.phone, isRequired: false),
      ],
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

  Widget _buildTextFormField({required String label, TextEditingController? controller, TextInputType? keyboardType, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8F9FA), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)),
      validator: isRequired ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null : null,
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items, String? value, ValueChanged<String?>? onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8F9FA), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none)),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'This field is required' : null,
    );
  }

  Widget _buildDatePickerField(BuildContext context, {required String label}) {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF8F9FA), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none), suffixIcon: const Icon(Icons.calendar_today)),
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (date != null) {
          _dateController.text = DateFormat('yyyy-MM-dd').format(date);
        }
      },
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
                onPressed: _isLoading ? null : _confirmDispatch,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  disabledBackgroundColor: const Color(0xFFD32F2F).withOpacity(0.6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Dispatch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('* Required fields', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
  }
}
