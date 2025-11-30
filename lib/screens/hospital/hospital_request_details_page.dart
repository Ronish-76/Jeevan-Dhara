import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:intl/intl.dart';
import 'package:jeevandhara/services/api_service.dart';

class HospitalRequestDetailsPage extends StatefulWidget {
  final BloodRequest request;

  const HospitalRequestDetailsPage({super.key, required this.request});

  @override
  State<HospitalRequestDetailsPage> createState() => _HospitalRequestDetailsPageState();
}

class _HospitalRequestDetailsPageState extends State<HospitalRequestDetailsPage> {
  late BloodRequest request;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    request = widget.request;
  }

  Future<void> _markAsFulfilled() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().fulfillHospitalBloodRequest(request.id, request.donorId);
      
      setState(() {
        request = request.copyWith(status: 'fulfilled');
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request marked as fulfilled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
    final isCritical = request.notifyViaEmergency;
    
    Color statusColor;
    switch (request.status.toLowerCase()) {
      case 'fulfilled': statusColor = Colors.green; break;
      case 'cancelled': statusColor = Colors.red; break;
      case 'pending': statusColor = Colors.orange; break;
      default: statusColor = Colors.blue;
    }

    // Button Logic: Only visible for non-completed requests made to donors
    bool isDonorRequest = request.requestedFrom == null || request.requestedFrom!.toLowerCase() == 'donor';
    bool canFulfill = isDonorRequest && request.status.toLowerCase() != 'fulfilled' && request.status.toLowerCase() != 'cancelled';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.05),
                border: const Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD32F2F), width: 2),
                    ),
                    child: Text(
                      request.bloodGroup,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${request.units} Units Required',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Request Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.calendar_today, 'Requested On', dateFormat.format(request.createdAt)),
                  _buildInfoTile(Icons.medical_services_outlined, 'Urgency', isCritical ? 'Critical / Emergency' : 'Standard'),
                  if (request.patientName.isNotEmpty && request.patientName != 'Unknown Patient')
                    _buildInfoTile(Icons.person_outline, 'Patient Name', request.patientName),
                  if (request.additionalDetails != null && request.additionalDetails!.isNotEmpty)
                    _buildInfoTile(Icons.notes, 'Notes', request.additionalDetails!),
                  
                  if (request.status.toLowerCase() == 'accepted' || request.status.toLowerCase() == 'fulfilled') ...[
                    const Divider(height: 32),
                    const Text('Donor Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildInfoTile(Icons.person, 'Donor Name', request.donorName ?? 'Unknown'),
                    if (request.donorId != null)
                       _buildInfoTile(Icons.badge, 'Donor ID', request.donorId!),
                  ],

                  const Divider(height: 32),
                  
                  const Text('Hospital Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoTile(Icons.local_hospital_outlined, 'Hospital', request.hospitalName.isNotEmpty ? request.hospitalName : 'N/A'),
                  _buildInfoTile(Icons.location_on_outlined, 'Location', request.location.isNotEmpty ? request.location : 'N/A'),
                  _buildInfoTile(Icons.phone_outlined, 'Contact', request.contactNumber.isNotEmpty ? request.contactNumber : 'N/A'),
                  
                  const SizedBox(height: 80), // Space for button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: canFulfill 
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _markAsFulfilled,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('MARK AS FULFILLED', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ) 
        : null,
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
