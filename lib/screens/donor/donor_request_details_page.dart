import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class DonorRequestDetailsPage extends StatefulWidget {
  final BloodRequest request;

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

  Future<void> _sendSMS(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  Future<void> _acceptRequest() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to accept requests')));
        return;
      }

      if (!user.isEligible) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You are currently in the 3-month waiting period.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }

      await ApiService().acceptBloodRequest(request.id, user.id!);
      
      setState(() {
        // Create a new BloodRequest with updated status
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
          donorId: user.id, // Update donorId locally
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted successfully! Thank you for your help.')),
      );
      
      // Navigator.pop(context); // Stay on page to show accepted status
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
            _buildUrgencyBanner(),
            _buildPatientInfoSection(),
            _buildMedicalContextSection(),
            _buildHospitalLocationSection(),
            _buildImportantNotesSection(),
            const SizedBox(height: 80), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildUrgencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _urgencyColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            _urgencyText,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patient Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Divider(height: 24),
          Row(
            children: [
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
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _urgencyColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    request.bloodGroup,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _urgencyColor),
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
        _buildDetailRow(label: 'Additional Details:', value: request.additionalDetails ?? 'None provided', valueColor: const Color(0xFFD32F2F)),
        _buildDetailRow(label: 'Requested By:', value: request.requesterName ?? 'Unknown'),
        const SizedBox(height: 8),
        Text(
          'Posted on: ${request.createdAt.toLocal().toString().split(' ')[0]}',
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
      ],
    );
  }

  Widget _buildImportantNotesSection() {
    return _buildSectionCard(
      title: 'Important Notes',
      icon: Icons.info_outline,
      children: const [
        Text(
          'Please ensure you meet donation eligibility criteria. Confirm availability before visiting the hospital.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
     return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFFD32F2F), size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: valueColor ?? Colors.black87, fontWeight: FontWeight.bold), textAlign: TextAlign.end,)),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    final user = Provider.of<AuthProvider>(context).user;
    final isMyAcceptedRequest = request.status == 'accepted' && user != null && request.donorId == user.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
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
                  onPressed: _acceptRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: const Text('ACCEPT REQUEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makePhoneCall(request.contactNumber),
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Call Hospital'),
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD32F2F), side: const BorderSide(color: Color(0xFFD32F2F)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendSMS(request.patientPhone),
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
