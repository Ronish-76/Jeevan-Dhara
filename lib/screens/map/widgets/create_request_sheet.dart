// lib/screens/map/widgets/create_request_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps


import 'package:jeevandhara/models/location_model.dart';

class NewRequestData {
  const NewRequestData({
    required this.requesterName,
    required this.requesterContact,
    required this.bloodGroup,
    required this.units,
    required this.location, // <-- 1. Add location
    this.notes,
  });

  final String requesterName;
  final String requesterContact;
  final String bloodGroup;
  final int units;
  final LatLng location; // <-- 1. Add location
  final String? notes;
}

class CreateRequestSheet extends StatefulWidget {
  const CreateRequestSheet({
    super.key,
    required this.role,
    required this.location, // <-- 2. Add location
  });

  final UserRole role;
  final LatLng location; // <-- 2. Add location

  // 3. Update show() method
  static Future<NewRequestData?> show(
      BuildContext context, {
        required UserRole role,
        required LatLng location, // <-- Required parameter
      }) {
    return showModalBottomSheet<NewRequestData>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CreateRequestSheet(role: role, location: location),
      ),
    );
  }

  @override
  State<CreateRequestSheet> createState() => _CreateRequestSheetState();
}

class _CreateRequestSheetState extends State<CreateRequestSheet> {
  // ... (controllers and dispose method remain the same) ...
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();
  String _bloodGroup = 'A+';
  int _units = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // ... (UI remains exactly the same, no changes needed here) ...
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Blood Request',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Requester Name'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Please enter name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(labelText: 'Contact Number'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Contact is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _bloodGroup,
              items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                  .map(
                    (group) =>
                    DropdownMenuItem(value: group, child: Text(group)),
              )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _bloodGroup = value ?? _bloodGroup),
              decoration: const InputDecoration(labelText: 'Blood Group'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Units'),
                const Spacer(),
                IconButton(
                  onPressed: _units > 1
                      ? () => setState(() => _units -= 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_units'),
                IconButton(
                  onPressed: _units < 10
                      ? () => setState(() => _units += 1)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit Request'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    // 4. Pass the location when creating NewRequestData
    Navigator.of(context).pop(
      NewRequestData(
        requesterName: _nameController.text.trim(),
        requesterContact: _contactController.text.trim(),
        bloodGroup: _bloodGroup,
        units: _units,
        location: widget.location, // <-- Use the location from the widget
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }
}
