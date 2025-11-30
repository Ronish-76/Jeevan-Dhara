import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';

class RequesterRequestDetailsScreen extends StatelessWidget {
  final BloodRequest request;

  const RequesterRequestDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Patient Name', request.patientName),
            _buildDetailRow('Blood Group', request.bloodGroup),
            _buildDetailRow('Hospital', request.hospitalName),
            _buildDetailRow('Location', request.location),
            _buildDetailRow('Contact', request.contactNumber),
            _buildDetailRow('Units', request.units.toString()),
            _buildDetailRow('Status', request.status),
            _buildDetailRow(
              'Emergency',
              request.notifyViaEmergency ? 'Yes' : 'No',
            ),
            if (request.additionalDetails != null &&
                request.additionalDetails!.isNotEmpty)
              _buildDetailRow('Additional Details', request.additionalDetails!),
            if ((request.status == 'accepted' || request.status == 'fulfilled') && request.donorName != null)
               _buildDetailRow('Donor Name', request.donorName!),
            if ((request.status == 'accepted' || request.status == 'fulfilled') && request.donorName == null)
               _buildDetailRow('Donor Name', 'Assigned (Name unavailable)'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
