import 'package:flutter/material.dart';
import 'package:jeevandhara/models/donor_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../user/find_donor_screen.dart';

class RequesterDonorProfileScreen extends StatelessWidget {
  final Donor donor;

  const RequesterDonorProfileScreen({super.key, required this.donor});

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

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
<<<<<<< HEAD
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
=======
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
>>>>>>> map-feature
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildStatisticsSection(),
            _buildInfoCard(
              title: 'Personal Information',
              details: {
                'Name': donor.name,
                if (donor.phone != null && donor.phone!.isNotEmpty) 'Contact': donor.phone!,
                if (donor.email != null && donor.email!.isNotEmpty) 'Email': donor.email!,
                'Location': donor.location,
              },
              icons: {
                'Name': Icons.person_outline,
                'Contact': Icons.phone_outlined,
                'Email': Icons.email_outlined,
                'Location': Icons.location_on_outlined,
              },
              actions: {
                if (donor.phone != null && donor.phone!.isNotEmpty)
                  'Contact': () => _makePhoneCall(donor.phone!),
                if (donor.email != null && donor.email!.isNotEmpty)
                  'Email': () => _sendEmail(donor.email!),
              },
            ),
            _buildInfoCard(
              title: 'Health Information',
              details: {
                'Blood Group': donor.bloodGroup,
                'Availability': donor.isAvailable ? 'Available' : 'Unavailable',
                'Last Donation': donor.lastDonationMonthsAgo > 0 ? '${donor.lastDonationMonthsAgo} months ago' : 'None recorded',
              },
              icons: {
                'Blood Group': Icons.bloodtype_outlined,
                'Availability': Icons.event_available_outlined,
                'Last Donation': Icons.calendar_today_outlined,
              },
            ),
            // Since we don't have real donation history in the donor list API yet, we might want to hide or show dummy data
            // For now, I will comment it out until we have an API for it, or show a message.
            // _buildDonationHistory(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 80, bottom: 30),
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
<<<<<<< HEAD
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Center(
                child: Text(
                  donor.bloodGroup,
                  style: const TextStyle(
                    color: Color(0xFFD32F2F),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
=======
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 80,
                color: Color(0xFFD32F2F),
              ), // Placeholder
>>>>>>> map-feature
            ),
            const SizedBox(height: 16),
            Text(
              donor.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  donor.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
             Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: donor.isAvailable ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  donor.isAvailable ? 'Available' : 'Unavailable',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
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
<<<<<<< HEAD
          _buildStatCard('${donor.totalDonations}', 'Donations', Icons.bloodtype),
          _buildStatCard('${donor.totalDonations * 3}', 'Lives Saved', Icons.favorite),
          _buildStatCard('${donor.lastDonationMonthsAgo}m', 'Last Donation', Icons.calendar_today),
=======
          _buildStatCard(
            '${donor.totalDonations}',
            'Donations Made',
            Icons.bloodtype,
          ),
          _buildStatCard(
            '${donor.totalDonations * 3}',
            'Lives Saved',
            Icons.favorite,
          ),
          _buildStatCard(
            '${donor.lastDonationMonthsAgo}m',
            'Last Donation',
            Icons.calendar_today,
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD32F2F), size: 28),
        ),
        const SizedBox(height: 8),
<<<<<<< HEAD
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
=======
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
>>>>>>> map-feature
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Map<String, String> details,
    required Map<String, IconData> icons,
<<<<<<< HEAD
    Map<String, VoidCallback>? actions,
=======
>>>>>>> map-feature
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
<<<<<<< HEAD
            ...details.entries.map((entry) {
              final hasAction = actions != null && actions.containsKey(entry.key);
              return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icons[entry.key], color: Colors.grey.shade700, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entry.key, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            Text(
                              entry.value,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                       if (hasAction)
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFD32F2F)),
                          onPressed: actions![entry.key],
                        ),
                    ],
                  ),
                );
            }),
=======
            ...details.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icons[entry.key], color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Flexible(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Color(0xFF666666)),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
>>>>>>> map-feature
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: (donor.isAvailable && donor.phone != null && donor.phone!.isNotEmpty)
              ? () => _makePhoneCall(donor.phone!)
              : null,
          icon: const Icon(Icons.phone),
          label: const Text('Call Donor Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
        ),
=======
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
            const Text(
              'Recent Donations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
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
          const Text(
            'Completed',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                backgroundColor: donor.isAvailable
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                donor.isAvailable ? 'Become Unavailable' : 'Become Available',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
>>>>>>> map-feature
      ),
    );
  }
}
