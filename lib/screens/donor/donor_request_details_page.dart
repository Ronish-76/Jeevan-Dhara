import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/donor_viewmodel.dart';

class DonorRequestDetailsPage extends StatelessWidget {
  final BloodRequestModel request;

  const DonorRequestDetailsPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUrgencyBanner(),
            _buildPatientInfoSection(),
            _buildMedicalContextSection(),
            _buildHospitalLocationSection(),
            _buildImportantNotesSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context),
    );
  }

  Widget _buildUrgencyBanner() {
    // This section is fine, assuming 'urgency' can be null.
    // We can add a check to only show the banner if urgency is specified.
    if (request.urgency == null || request.urgency!.isEmpty) {
      return const SizedBox.shrink(); // Don't show banner if no urgency
    }

    final urgencyColor = request.urgency == 'critical'
        ? const Color(0xFFB71C1C)
        : const Color(0xFFD32F2F);

    return Container(
      padding: const EdgeInsets.all(16),
      color: urgencyColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Urgent Request: ${request.urgency!.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patient Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Divider(height: 24),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.requesterName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Units Required: ${request.units}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${request.status}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD32F2F).withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    // FIX #1: 'bloodType' was a getter, use the actual field 'bloodGroup' for consistency.
                    request.bloodGroup,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalContextSection() {
    return _buildSectionCard(
      title: 'Medical Information',
      icon: Icons.medical_services_outlined,
      children: [
        // FIX #2: The 'reason' field was removed from the model. This entire block is removed.

        // FIX #3: Added a null-check for 'createdAt' to prevent runtime errors.
        if (request.createdAt != null)
          _buildDetailRow(
            label: 'Requested On:',
            value: request.createdAt!.toLocal().toString().split('.').first,
          ),
        const SizedBox(height: 8),
        Text(
          request.notes ??
              'Patient requires compatible donor as soon as possible. Please confirm availability before heading to hospital.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHospitalLocationSection() {
    return _buildSectionCard(
      title: 'Hospital Location',
      icon: Icons.local_hospital_outlined,
      children: [
        Text(
          // Using locationName as the title, providing a fallback.
          request.locationName ?? 'Unknown Location',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          // FIX #4 & #5: Changed 'latitude' to 'lat' and 'longitude' to 'lng'.
          onPressed: request.lat != 0 && request.lng != 0
              ? () async {
            final url =
                'https://www.google.com/maps/dir/?api=1&destination=${request.lat},${request.lng}';
            await launchUrlString(url);
          }
              : null,
          icon: const Icon(Icons.navigation_outlined, color: Color(0xFFD32F2F)),
          label: const Text(
            'Open in Maps',
            style: TextStyle(color: Color(0xFFD32F2F)),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD32F2F)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportantNotesSection() {
    // This section is fine as 'notes' is still a valid field.
    return _buildSectionCard(
      title: 'Important Notes',
      icon: Icons.info_outline,
      children: [
        Text(
          request.notes ??
              'Please ensure you meet donation eligibility criteria. Confirm availability before visiting the hospital.',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // --- No changes needed for the helper methods below this line ---

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD32F2F), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: request.requesterContact.isNotEmpty
                  ? () async =>
              await launchUrlString('tel:${request.requesterContact}')
                  : null,
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Call Contact'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleRespond(context),
              icon: const Icon(Icons.bloodtype, size: 18),
              label: const Text('Donate Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRespond(BuildContext context) async {
    final provider = context.read<DonorViewModel>();
    final details = await _promptResponderDetails(context);
    if (details == null) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Submitting response...')));
    try {
      await provider.respondToRequest(
        request: request,
        responderName: details['name']!,
        responderContact: details['contact'],
        notes: details['notes'],
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thanks! Request updated.')));
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<Map<String, String?>?> _promptResponderDetails(BuildContext context) {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, String?>?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Responder Details'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact (optional)',
                ),
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(ctx).pop({
                'name': nameController.text.trim(),
                'contact': contactController.text.trim().isEmpty
                    ? null
                    : contactController.text.trim(),
                'notes': notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              });
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
