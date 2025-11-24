import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class DonorRequestDetailsPage extends StatefulWidget {
  final BloodRequest request;
=======
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/donor_viewmodel.dart';

class DonorRequestDetailsPage extends StatelessWidget {
  final BloodRequestModel request;
>>>>>>> map-feature

  const DonorRequestDetailsPage({super.key, required this.request});

  @override
  State<DonorRequestDetailsPage> createState() => _DonorRequestDetailsPageState();
}

class _DonorRequestDetailsPageState extends State<DonorRequestDetailsPage> {
  late BloodRequest request;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    request = widget.request;
  }

  Color get _urgencyColor => request.notifyViaEmergency ? const Color(0xFFB71C1C) : const Color(0xFF2196F3);

  String get _urgencyText => request.notifyViaEmergency ? 'Urgent Request: Immediate Attention Needed' : 'Standard Request';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _acceptRequest() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && !user.isEligible) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You are currently in the 3-month waiting period and cannot accept new requests.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to accept requests')));
        return;
      }

      await ApiService().acceptBloodRequest(request.id, user.id!);
      
      setState(() {
        request = BloodRequest(
          id: request.id,
          patientName: request.patientName,
          patientPhone: request.patientPhone,
          bloodGroup: request.bloodGroup,
          hospitalName: request.hospitalName,
          location: request.location,
          contactNumber: request.contactNumber,
          additionalDetails: request.additionalDetails,
          units: request.units,
          notifyViaEmergency: request.notifyViaEmergency,
          status: 'accepted',
          createdAt: request.createdAt,
          requesterName: request.requesterName,
          donorId: user.id,
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully! Thank you for your help.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fulfillRequest() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      await ApiService().fulfillBloodRequest(request.id, user.id!);
      
      setState(() {
        request = BloodRequest(
          id: request.id,
          patientName: request.patientName,
          patientPhone: request.patientPhone,
          bloodGroup: request.bloodGroup,
          hospitalName: request.hospitalName,
          location: request.location,
          contactNumber: request.contactNumber,
          additionalDetails: request.additionalDetails,
          units: request.units,
          notifyViaEmergency: request.notifyViaEmergency,
          status: 'fulfilled',
          createdAt: request.createdAt,
          requesterName: request.requesterName,
          donorId: request.donorId,
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request marked as completed! Thank you for your donation.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete request: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isEligible = user?.isEligible ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request Details'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        child: Column(
          children: [
            if (!isEligible && request.status == 'pending')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You are currently ineligible to donate due to the waiting period.',
                        style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            _buildUrgencyBanner(),
            _buildPatientInfoSection(),
            _buildMedicalContextSection(),
            _buildHospitalLocationSection(),
            _buildImportantNotesSection(),
            const SizedBox(height: 80), // Space for bottom bar
          ],
        ),
      ),
<<<<<<< HEAD
      bottomNavigationBar: _buildActionButtons(isEligible),
=======
      bottomNavigationBar: _buildActionButtons(context),
>>>>>>> map-feature
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
<<<<<<< HEAD
      color: _urgencyColor,
=======
      color: urgencyColor,
>>>>>>> map-feature
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
<<<<<<< HEAD
            _urgencyText,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
=======
            'Urgent Request: ${request.urgency!.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
>>>>>>> map-feature
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
<<<<<<< HEAD
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${request.units} Unit${request.units > 1 ? 's' : ''} Required', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(request.patientPhone, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
=======
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
>>>>>>> map-feature
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
<<<<<<< HEAD
                  color: _urgencyColor.withOpacity(0.1),
=======
                  color: const Color(0xFFD32F2F).withOpacity(0.1),
>>>>>>> map-feature
                ),
                child: Center(
                  child: Text(
                    // FIX #1: 'bloodType' was a getter, use the actual field 'bloodGroup' for consistency.
                    request.bloodGroup,
<<<<<<< HEAD
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _urgencyColor),
=======
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
>>>>>>> map-feature
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
<<<<<<< HEAD
        _buildDetailRow(label: 'Additional Details:', value: request.additionalDetails ?? 'None provided', valueColor: const Color(0xFFD32F2F)),
        _buildDetailRow(label: 'Requested By:', value: request.requesterName ?? 'Unknown'),
        const SizedBox(height: 8),
        Text(
          'Posted on: ${request.createdAt.toLocal().toString().split(' ')[0]}',
=======
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
>>>>>>> map-feature
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
<<<<<<< HEAD
         Text(request.hospitalName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
         const SizedBox(height: 4),
         Text(request.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
         const SizedBox(height: 12),
         OutlinedButton.icon(
           onPressed: (){},
           icon: const Icon(Icons.navigation_outlined, color: Color(0xFFD32F2F)),
           label: const Text('Open in Maps', style: TextStyle(color: Color(0xFFD32F2F))),
           style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD32F2F)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
         ),
=======
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
>>>>>>> map-feature
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
<<<<<<< HEAD
  
  Widget _buildActionButtons(bool isEligible) {
    final user = Provider.of<AuthProvider>(context).user;
    final isMyAcceptedRequest = request.status == 'accepted' && user != null && request.donorId == user.id;

=======

  Widget _buildActionButtons(BuildContext context) {
>>>>>>> map-feature
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (request.status == 'pending')
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isEligible ? _acceptRequest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: isEligible ? 3 : 0,
                  ),
                  child: Text(
                    isEligible ? 'ACCEPT REQUEST' : 'NOT ELIGIBLE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isEligible ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),

          if (request.status == 'accepted')
             Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: isMyAcceptedRequest 
                  ? ElevatedButton(
                      onPressed: _fulfillRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: const Text('MARK AS COMPLETED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  : ElevatedButton.icon(
                      onPressed: null, // Disabled
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('ACCEPTED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey, // Grey out if not my request
                        disabledBackgroundColor: Colors.grey.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
              ),
            ),
          if (request.status == 'fulfilled')
             Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('COMPLETED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
<<<<<<< HEAD
              onPressed: () => _makePhoneCall(request.contactNumber),
=======
              onPressed: request.requesterContact.isNotEmpty
                  ? () async =>
              await launchUrlString('tel:${request.requesterContact}')
                  : null,
>>>>>>> map-feature
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
<<<<<<< HEAD
=======
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
>>>>>>> map-feature
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
