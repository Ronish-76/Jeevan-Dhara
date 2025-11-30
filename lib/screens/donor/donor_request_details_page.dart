import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:flutter_translate/flutter_translate.dart';

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

  String get _urgencyText => request.notifyViaEmergency ? translate('urgent_request_needed') : translate('standard_request');

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

  Future<void> _openMap() async {
    // Combine hospital name and location for better search accuracy
    final searchTerm = '${request.hospitalName} ${request.location}';
    final query = Uri.encodeComponent(searchTerm);
    final googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('could_not_open_maps'))),
        );
      }
    }
  }

  Future<void> _acceptRequest() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && !user.isEligible) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(translate('ineligible_waiting_period')),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translate('must_be_logged_in'))));
        return;
      }

      if (request.isHospitalRequest) {
         // Use specific method for hospital requests which might try alternative endpoints
         await ApiService().acceptHospitalBloodRequest(request.id, user.id!);
      } else {
         await ApiService().acceptBloodRequest(request.id, user.id!);
      }
      
      setState(() {
        request = request.copyWith(
          status: 'accepted',
          donorId: user.id,
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('request_accepted_success'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${translate('failed_accept_request')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fulfillRequest() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user == null) return;

      // Complete the request
      if (request.isHospitalRequest) {
         await ApiService().fulfillHospitalBloodRequest(request.id, user.id!);
      } else {
         await ApiService().fulfillBloodRequest(request.id, user.id!);
      }
      
      await authProvider.refreshUserProfile();

      setState(() {
        request = request.copyWith(status: 'fulfilled');
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('request_completed_success'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${translate('failed_complete_request')}: $e')),
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
        title: Text(translate('request_details')),
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
                        translate('ineligible_donate_msg'),
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
      bottomNavigationBar: _buildActionButtons(isEligible),
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
          Text(translate('patient_details'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.patientName.isNotEmpty ? request.patientName : (request.hospitalName.isNotEmpty ? request.hospitalName : "Hospital Request"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${request.units} ${request.units > 1 ? translate('units') : translate('unit')} ${translate('required')}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(request.patientPhone.isNotEmpty ? request.patientPhone : request.contactNumber, style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
      title: translate('medical_information'),
      icon: Icons.medical_services_outlined,
      children: [
        _buildDetailRow(label: '${translate('additional_details')}:', value: request.additionalDetails ?? translate('none_provided'), valueColor: const Color(0xFFD32F2F)),
        _buildDetailRow(label: '${translate('requested_by')}:', value: request.requesterName ?? request.hospitalName),
        const SizedBox(height: 8),
        Text(
          '${translate('posted_on')}: ${request.createdAt.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

   Widget _buildHospitalLocationSection() {
    return _buildSectionCard(
      title: translate('hospital_location'),
      icon: Icons.local_hospital_outlined,
      children: [
         Text(request.hospitalName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
         const SizedBox(height: 4),
         Text(request.location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
         const SizedBox(height: 12),
         OutlinedButton.icon(
           onPressed: _openMap,
           icon: const Icon(Icons.navigation_outlined, color: Color(0xFFD32F2F)),
           label: Text(translate('open_in_maps'), style: const TextStyle(color: Color(0xFFD32F2F))),
           style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD32F2F)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
         ),
      ],
    );
  }

  Widget _buildImportantNotesSection() {
    return _buildSectionCard(
      title: translate('important_notes'),
      icon: Icons.info_outline,
      children: [
        Text(
          translate('important_notes_msg'),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
  
  Widget _buildActionButtons(bool isEligible) {
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
          if (request.status == 'pending' && !request.isHospitalRequest)
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
                    isEligible ? translate('accept_request').toUpperCase() : translate('not_eligible').toUpperCase(),
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
                      child: Text(translate('mark_as_completed').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  : ElevatedButton.icon(
                      onPressed: null, // Disabled
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: Text(translate('accepted').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  label: Text(translate('completed').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
              onPressed: () => _makePhoneCall(request.contactNumber),
              icon: const Icon(Icons.call, size: 18),
              label: Text(translate('call_hospital')),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD32F2F), side: const BorderSide(color: Color(0xFFD32F2F)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
            ),
          ),
        ],
      ),
    );
  }
}
