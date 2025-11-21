import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/donor/donor_donation_history_page.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  _DonorProfilePageState createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  late Future<User> _donorFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _donorFuture = _fetchDonorProfile(authProvider.user!.id!);
  }

  Future<User> _fetchDonorProfile(String userId) async {
    final response = await http.get(
      Uri.parse('http://your_backend_ip:5000/api/donors/$userId'),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load donor profile');
    }
  }

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
      body: FutureBuilder<User>(
        future: _donorFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final donor = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(donor),
                  _buildDonationStatistics(donor),
                  _buildEligibilityCard(donor),
                  _buildInfoCard(donor),
                  _buildAccountManagementCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(User donor) {
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
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 50, color: Color(0xFFD32F2F)),
          ),
          const SizedBox(height: 12),
          Text(
            donor.fullName ?? 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Blood Group: ${donor.bloodGroup ?? 'N/A'}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Member since January 2022',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationStatistics(User donor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            donor.totalDonations.toString(),
            'Donations',
            Icons.bloodtype_outlined,
          ),
          _buildStatCard(
            '18',
            'Units',
            Icons.favorite_border,
          ), // Assuming 'Units' is not in the model
          _buildStatCard(
            '2+',
            'Years',
            Icons.calendar_today_outlined,
          ), // Assuming 'Years' is calculated
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

  Widget _buildEligibilityCard(User donor) {
    final isEligible = donor.isEligible;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEligible
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFEBEE), // Light Green or Light Red
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEligible ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEligible ? Icons.check_circle_outline : Icons.highlight_off,
            color: isEligible
                ? const Color(0xFF4CAF50)
                : const Color(0xFFD32F2F),
          ),
          const SizedBox(width: 12),
          Text(
            isEligible ? 'Eligible to Donate' : 'Not Eligible to Donate',
            style: TextStyle(
              color: isEligible
                  ? const Color(0xFF388E3C)
                  : const Color(0xFFD32F2F),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(User donor) {
    return _buildSectionCard(
      title: 'Personal Information',
      children: [
        _buildInfoRow(
          Icons.phone_outlined,
          'Phone Number',
          donor.phone ?? 'N/A',
        ),
        _buildInfoRow(Icons.email_outlined, 'Email', donor.email ?? 'N/A'),
        _buildInfoRow(
          Icons.location_on_outlined,
          'Location',
          donor.location ?? 'N/A',
        ),
        _buildInfoRow(
          Icons.calendar_today_outlined,
          'Last Donation',
          donor.lastDonationDate?.toString().split(' ')[0] ?? 'N/A',
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
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
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
