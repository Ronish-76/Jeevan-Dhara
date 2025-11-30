import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

class HospitalProfilePage extends StatefulWidget {
  const HospitalProfilePage({super.key});

  @override
  State<HospitalProfilePage> createState() => _HospitalProfilePageState();
}

class _HospitalProfilePageState extends State<HospitalProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      setState(() {
        _profileFuture = _fetchProfile(user.id!);
      });
    } else {
      setState(() {
        _profileFuture = Future.error('User not logged in');
      });
    }
  }

  Future<void> _refreshProfile() async {
    _loadProfile();
    try {
      await _profileFuture;
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _fetchProfile(String id) async {
    try {
      final data = await ApiService().get('auth/profile/hospital/$id');
      return data;
    } catch (e) {
      throw Exception('Failed to load profile: $e');
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Hospital Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                ],
              );
            }
            if (!snapshot.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(child: Text('No data found')),
                  ),
                ],
              );
            }

            final profile = snapshot.data!;
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(profile),
                  const SizedBox(height: 20),
                  _buildBasicInfoCard(profile),
                  const SizedBox(height: 20),
                  _buildAboutHospitalCard(profile),
                  const SizedBox(height: 20),
                  _buildFacilitiesCard(profile),
                  const SizedBox(height: 30),
                  _buildLogoutButton(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F), // Red background
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile) {
    final name = profile['hospitalName'] ?? 'Unknown Hospital';
    final isVerified = profile['isVerified'] == true;
    final type = profile['hospitalType']?.toString().toUpperCase() ?? 'HOSPITAL';
    final estYear = profile['createdAt'] != null ? DateTime.parse(profile['createdAt']).year : DateTime.now().year;

    return Column(
      children: [
        Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        if (isVerified)
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified, color: Colors.green, size: 16),
              SizedBox(width: 4),
              Text('Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        const SizedBox(height: 4),
        Text('$type • Joined $estYear', style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBasicInfoCard(Map<String, dynamic> profile) {
    final address = '${profile['address'] ?? ''}, ${profile['city'] ?? ''}'.trim();
    
    return _buildInfoCard(
      title: 'Basic Information',
      children: [
        _buildInfoRow(Icons.local_hospital_outlined, 'Hospital Name', profile['hospitalName'] ?? 'N/A'),
        _buildInfoRow(Icons.location_on_outlined, 'Address', address.isNotEmpty ? address : 'N/A'),
        _buildInfoRow(Icons.badge_outlined, 'Registration ID', profile['hospitalRegistrationId'] ?? 'N/A'),
        _buildInfoRow(Icons.phone_outlined, 'Contact Number', profile['phoneNumber'] ?? 'N/A', isTappable: true),
        _buildInfoRow(Icons.email_outlined, 'Email', profile['email'] ?? 'N/A', isTappable: true),
        _buildInfoRow(Icons.person_outline, 'Contact Person', profile['contactPerson'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildAboutHospitalCard(Map<String, dynamic> profile) {
    final type = profile['hospitalType'] ?? 'general';
    final desc = 'A registered $type hospital located in ${profile['city'] ?? 'Nepal'}, committed to providing quality healthcare services.';

    return _buildInfoCard(
      title: 'About Hospital',
      children: [
        Text(
          desc,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        )
      ],
    );
  }

  Widget _buildFacilitiesCard(Map<String, dynamic> profile) {
    final hasBloodBank = profile['bloodBankFacility'] == true;
    final hasEmergency = profile['emergencyService24x7'] == true;

    // Create a list of facilities based on available data
    final facilities = [
      {'name': 'Blood Bank Facility', 'available': hasBloodBank},
      {'name': 'Emergency Service', 'available': hasEmergency},
      // Add others if backend supports them in future
    ];

    return _buildInfoCard(
      title: 'Key Facilities',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Single column for clarity with fewer items
            childAspectRatio: 6, 
            mainAxisSpacing: 4,
            crossAxisSpacing: 8,
          ),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final item = facilities[index];
            final isAvailable = item['available'] as bool;
            return Row(
              children: [
                Icon(isAvailable ? Icons.check_circle : Icons.cancel, color: isAvailable ? Colors.green : Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(item['name'] as String, style: const TextStyle(fontSize: 14))),
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
