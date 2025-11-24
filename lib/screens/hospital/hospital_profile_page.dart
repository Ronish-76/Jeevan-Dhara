import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

=======
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';

>>>>>>> map-feature
class HospitalProfilePage extends StatefulWidget {
  const HospitalProfilePage({super.key});

  @override
  State<HospitalProfilePage> createState() => _HospitalProfilePageState();
}

class _HospitalProfilePageState extends State<HospitalProfilePage> {
<<<<<<< HEAD
  late Future<Map<String, dynamic>> _profileFuture;
=======
  bool _initialized = false;
>>>>>>> map-feature

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      _profileFuture = _fetchProfile(user.id!);
    } else {
      _profileFuture = Future.error('User not logged in');
    }
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
=======
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final inventoryViewModel = context.read<InventoryViewModel>();
    if (inventoryViewModel.nearbyFacilities.isEmpty) {
      await inventoryViewModel.fetchNearbyFacilities(role: UserRole.hospital);
    }
    if (mounted) {
      setState(() => _initialized = true);
>>>>>>> map-feature
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Hospital Profile'),
<<<<<<< HEAD
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final profile = snapshot.data!;
          return SingleChildScrollView(
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
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'LOGOUT',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F), // Red background
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
=======
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(facility),
              const SizedBox(height: 20),
              _buildBasicInfoCard(facility),
              const SizedBox(height: 20),
              _buildAboutHospitalCard(facility),
              const SizedBox(height: 20),
              _buildFacilitiesCard(facility),
            ],
          ),
>>>>>>> map-feature
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildProfileHeader(facility) {
    return Column(
      children: [
        Text(
          facility?.name ?? 'Hospital',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Verified',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          facility?.displayAddress ?? 'Hospital',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
>>>>>>> map-feature
      ],
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildBasicInfoCard(facility) {
    return _buildInfoCard(
      title: 'Basic Information',
      children: [
        _buildInfoRow(
          Icons.local_hospital_outlined,
          'Hospital Name',
          facility?.name ?? 'Hospital',
        ),
        _buildInfoRow(
          Icons.location_on_outlined,
          'Address',
          facility?.displayAddress ?? 'Address not available',
        ),
        _buildInfoRow(
          Icons.badge_outlined,
          'Facility ID',
          facility?.id ?? 'N/A',
        ),
        _buildInfoRow(
          Icons.phone_outlined,
          'Contact Number',
          facility?.contactNumber ?? 'Not available',
          isTappable: facility?.contactNumber != null,
        ),
        if (facility?.email != null)
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            facility!.email!,
            isTappable: true,
          ),
>>>>>>> map-feature
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildAboutHospitalCard(Map<String, dynamic> profile) {
    final type = profile['hospitalType'] ?? 'general';
    final desc = 'A registered $type hospital located in ${profile['city'] ?? 'Nepal'}, committed to providing quality healthcare services.';

=======
  Widget _buildAboutHospitalCard(facility) {
>>>>>>> map-feature
    return _buildInfoCard(
      title: 'About Hospital',
      children: [
        Text(
<<<<<<< HEAD
          desc,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        )
=======
          facility?.name != null
              ? '${facility!.name} provides comprehensive healthcare services including emergency care, surgery, and specialized treatments.'
              : 'Hospital information not available.',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
>>>>>>> map-feature
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildFacilitiesCard(Map<String, dynamic> profile) {
    final hasBloodBank = profile['bloodBankFacility'] == true;
    final hasEmergency = profile['emergencyService24x7'] == true;

    // Create a list of facilities based on available data
    final facilities = [
      {'name': 'Blood Bank Facility', 'available': hasBloodBank},
      {'name': '24x7 Emergency Service', 'available': hasEmergency},
      // Add others if backend supports them in future
    ];
=======
  Widget _buildFacilitiesCard(facility) {
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
>>>>>>> map-feature

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
<<<<<<< HEAD
                Icon(isAvailable ? Icons.check_circle : Icons.cancel, color: isAvailable ? Colors.green : Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(item['name'] as String, style: const TextStyle(fontSize: 14))),
=======
                Icon(
                  facilities[key]!
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: facilities[key]! ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(key, style: const TextStyle(fontSize: 12)),
                ),
>>>>>>> map-feature
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isTappable = false,
  }) {
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
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isTappable
                        ? const Color(0xFF2196F3)
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
