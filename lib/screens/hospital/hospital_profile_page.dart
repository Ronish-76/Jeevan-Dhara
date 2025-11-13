import 'package:flutter/material.dart';

class HospitalProfilePage extends StatelessWidget {
  const HospitalProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Hospital Profile'),
        actions: [TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(color: Colors.white)))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildBasicInfoCard(),
            const SizedBox(height: 20),
            _buildAboutHospitalCard(),
            const SizedBox(height: 20),
            _buildFacilitiesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return const Column(
      children: [
        Text('Bir Hospital', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text('Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 4),
        Text('Government Hospital • Est. 1889', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildInfoCard(
      title: 'Basic Information',
      children: [
        _buildInfoRow(Icons.local_hospital_outlined, 'Hospital Name', 'Bir Hospital'),
        _buildInfoRow(Icons.location_on_outlined, 'Address', 'Mahabouddha, Kathmandu'),
        _buildInfoRow(Icons.badge_outlined, 'Registration ID', 'BH-2024-00123'),
        _buildInfoRow(Icons.phone_outlined, 'Contact Number', '+977 1-4221119', isTappable: true),
        _buildInfoRow(Icons.email_outlined, 'Email', 'info@birhospital.gov.np', isTappable: true),
      ],
    );
  }

  Widget _buildAboutHospitalCard() {
    return _buildInfoCard(
      title: 'About Hospital',
      children: const [
        Text(
          'Bir Hospital is one of the oldest and largest hospitals in Nepal, providing comprehensive healthcare services including emergency care, surgery, and specialized treatments.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        )
      ],
    );
  }

  Widget _buildFacilitiesCard() {
    final facilities = {
      'Emergency Services': true,
      'Blood Bank': true,
      'Intensive Care Unit (ICU)': true,
      'Operation Theater': true,
      'Laboratory Services': true,
      'Ambulance Services': true,
       '24/7 Service': true,
      'Radiology Department': false,
      'Pharmacy': false,
    };

    return _buildInfoCard(
      title: 'Available Facilities',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 5, // Adjust for checkbox list
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final key = facilities.keys.elementAt(index);
            return Row(
              children: [
                Icon(facilities[key]! ? Icons.check_box : Icons.check_box_outline_blank, color: facilities[key]! ? Colors.green : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(key, style: const TextStyle(fontSize: 12))),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), const Divider(height: 24), ...children],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isTappable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 15, color: isTappable ? const Color(0xFF2196F3) : Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
