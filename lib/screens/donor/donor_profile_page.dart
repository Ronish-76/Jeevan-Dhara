import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/donor/donor_donation_history_page.dart';

class DonorProfilePage extends StatelessWidget {
  const DonorProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildDonationStatistics(),
            _buildEligibilityCard(),
            _buildInfoCard(),
            _buildAccountManagementCard(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 80, bottom: 30, left: 20, right: 20),
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
      child: const Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Color(0xFFD32F2F)),
          ),
          SizedBox(height: 12),
          Text(
            'Rajesh Kumar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Blood Group: A+',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Member since January 2022',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('12', 'Donations', Icons.bloodtype_outlined),
          _buildStatCard('18', 'Units', Icons.favorite_border),
          _buildStatCard('2+', 'Years', Icons.calendar_today_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD32F2F), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light Green
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50)),
          SizedBox(width: 12),
          Text(
            'Eligible to Donate',
            style: TextStyle(
              color: Color(0xFF388E3C),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildSectionCard(
      title: 'Personal Information',
      children: [
        _buildInfoRow(Icons.phone_outlined, 'Phone Number', '+977 9841234567'),
        _buildInfoRow(Icons.email_outlined, 'Email', 'rajesh.kumar@email.com'),
        _buildInfoRow(
          Icons.location_on_outlined,
          'Location',
          'Kathmandu, Nepal',
        ),
        _buildInfoRow(
          Icons.calendar_today_outlined,
          'Last Donation',
          'March 15, 2024',
        ),
      ],
    );
  }

  Widget _buildAccountManagementCard(BuildContext context) {
    return _buildSectionCard(
      title: 'Account Management',
      children: [
        _buildManagementRow(
          Icons.notifications_outlined,
          'Notifications',
          trailing: Switch(
            value: true,
            onChanged: (val) {},
            activeColor: const Color(0xFFD32F2F),
          ),
        ),
        _buildManagementRow(Icons.share_outlined, 'Share Jeevan Dhara'),
        _buildManagementRow(
          Icons.history_outlined,
          'View Donation History',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DonorDonationHistoryPage(),
              ),
            );
          },
        ),
        const Divider(height: 24),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
            label: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
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
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Color(0xFF666666))),
        ],
      ),
    );
  }

  Widget _buildManagementRow(
    IconData icon,
    String label, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF666666)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
