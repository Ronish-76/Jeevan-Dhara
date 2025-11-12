import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/user/find_donor_screen.dart'; // Assuming Donor model is here

class DonorProfileScreen extends StatelessWidget {
  final Donor donor;

  const DonorProfileScreen({super.key, required this.donor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildStatisticsSection(),
            _buildInfoCard(
              title: 'Personal Information',
              details: {
                'Age': '28 years', // Sample Data
                'Contact': '+977-98XXXXXXX',
                'Email': 'sammy@example.com',
                'Preferred Hospital': 'Grande Hospital',
                'Address': 'Kathmandu, Nepal',
              },
              icons: {
                'Age': Icons.person_outline,
                'Contact': Icons.phone_outlined,
                'Email': Icons.email_outlined,
                'Preferred Hospital': Icons.local_hospital_outlined,
                'Address': Icons.location_on_outlined,
              },
            ),
            _buildInfoCard(
              title: 'Health Information',
              details: {
                'Blood Group': donor.bloodGroup,
                'Health Status': 'Excellent', // Sample Data
                'Last Checkup': '2 months ago',
                'Medical Conditions': 'None',
              },
               icons: {
                'Blood Group': Icons.bloodtype_outlined,
                'Health Status': Icons.health_and_safety_outlined,
                'Last Checkup': Icons.event_note_outlined,
                'Medical Conditions': Icons.medical_information_outlined,
              },
            ),
            _buildDonationHistory(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 80, color: Color(0xFFD32F2F)), // Placeholder
            ),
            const SizedBox(height: 12),
            Text(
              donor.name,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(donor.location, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('${donor.totalDonations}', 'Donations Made', Icons.bloodtype),
          _buildStatCard('${donor.totalDonations * 3}', 'Lives Saved', Icons.favorite),
          _buildStatCard('${donor.lastDonationMonthsAgo}m', 'Last Donation', Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required Map<String, String> details, required Map<String, IconData> icons}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...details.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icons[entry.key], color: Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Flexible(
                        child: Text(
                          entry.value,
                          style: const TextStyle(color: Color(0xFF666666)),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationHistory() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildHistoryItem('Jan 12, 2024', 'Kathmandu Medical College'),
            _buildHistoryItem('Oct 05, 2023', 'Grande Hospital'),
            _buildHistoryItem('May 21, 2023', 'Bir Hospital'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String hospital) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text('$date - $hospital')),
          const Text('Completed', style: TextStyle(color: Colors.green, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: donor.isAvailable ? const Color(0xFFD32F2F) : const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(donor.isAvailable ? 'Become Unavailable' : 'Become Available', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
