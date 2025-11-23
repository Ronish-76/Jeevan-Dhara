import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/services/api_service.dart';

class DonorProfilePage extends StatefulWidget {
  const DonorProfilePage({super.key});

  @override
  _DonorProfilePageState createState() => _DonorProfilePageState();
}

class _DonorProfilePageState extends State<DonorProfilePage> {
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null && authProvider.user!.id != null) {
      _profileDataFuture = _fetchProfileData(authProvider.user!.id!);
    } else {
      _profileDataFuture = Future.error('User not logged in');
    }
  }

  Future<Map<String, dynamic>> _fetchProfileData(String userId) async {
    try {
      // Fetch user profile
      final profileData = await ApiService().get('auth/profile/donor/$userId');
      final user = User.fromJson(profileData);

      // Fetch donation history to calculate units
      final historyData = await ApiService().getDonorDonationHistory(userId);
      final history = (historyData as List).map((e) => BloodRequest.fromJson(e)).toList();
      
      int totalUnits = 0;
      for (var req in history) {
        if (req.status == 'fulfilled') {
           totalUnits += req.units;
        }
      }

      // If backend totalDonations is 0 but history has fulfilled items, use history count
      // (Backend usually updates totalDonations on fulfill, so user.totalDonations should be accurate)
      int totalDonations = user.totalDonations;
      if (totalDonations == 0 && history.isNotEmpty) {
         totalDonations = history.where((r) => r.status == 'fulfilled').length;
      }

      return {
        'user': user,
        'totalUnits': totalUnits,
        'totalDonations': totalDonations,
      };
    } catch (e) {
      throw Exception('Failed to load profile data: $e');
    }
  }

  Future<void> _handleLogout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!['user'] as User;
            final totalUnits = snapshot.data!['totalUnits'] as int;
            final totalDonations = snapshot.data!['totalDonations'] as int;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  _buildDonationStatistics(totalDonations, totalUnits),
                  _buildEligibilityCard(user),
                  _buildInfoCard(user),
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
          // Removed "Member since..." as requested
        ],
      ),
    );
  }

  Widget _buildDonationStatistics(int donations, int units) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centered since fewer items
        children: [
          _buildStatCard(
            donations.toString(),
            'Donations',
            Icons.bloodtype_outlined,
          ),
          const SizedBox(width: 40),
          _buildStatCard(
            units.toString(),
            'Units',
            Icons.favorite_border,
          ),
          // Removed "Years" as requested
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
            : const Color(0xFFFFEBEE), 
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
        // Removed Notifications, Share, View History as requested
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _handleLogout,
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

  // Removed unused _buildManagementRow
}
