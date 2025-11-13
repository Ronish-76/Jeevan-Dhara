import 'package:flutter/material.dart';

// Simple model for request data
class BloodRequest {
  final String patientName;
  final String hospitalName;
  final String bloodGroup;
  final String urgency;
  final String distance;
  final String time;
  final Color urgencyColor;

  const BloodRequest({
    required this.patientName,
    required this.hospitalName,
    required this.bloodGroup,
    required this.urgency,
    required this.distance,
    required this.time,
    required this.urgencyColor,
  });
}

class DonorRequestDetailsPage extends StatelessWidget {
  final BloodRequest request;

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
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildUrgencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: request.urgencyColor,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Urgent Request: Immediate Attention Needed',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.patientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Age: 45 years', style: TextStyle(color: Colors.grey, fontSize: 14)),
                   const SizedBox(height: 4),
                  Text('Units Required: 2 Units', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: request.urgencyColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    request.bloodGroup,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: request.urgencyColor),
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
        _buildDetailRow(label: 'Reason:', value: 'Surgery - Cardiac Operation', valueColor: const Color(0xFFD32F2F)),
        _buildDetailRow(label: 'Required By:', value: 'May 17, 2024'),
        const SizedBox(height: 8),
        const Text(
          'Patient is scheduled for heart surgery. Blood must be arranged before May 17th morning.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

   Widget _buildHospitalLocationSection() {
    return _buildSectionCard(
      title: 'Hospital Location',
      icon: Icons.local_hospital_outlined,
      children: [
         const Text('Bir Hospital', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
         const SizedBox(height: 4),
         const Text('Kathmandu 44600, Nepal', style: TextStyle(color: Colors.grey, fontSize: 14)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: (){},
              icon: const Icon(Icons.call, size: 18),
              label: const Text('Call Hospital'),
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD32F2F), side: const BorderSide(color: Color(0xFFD32F2F)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: (){},
              icon: const Icon(Icons.bloodtype, size: 18),
              label: const Text('Donate Now'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
            ),
          ),
        ],
      ),
    );
  }
}
