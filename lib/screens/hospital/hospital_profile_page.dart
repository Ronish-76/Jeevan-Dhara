import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';

class HospitalProfilePage extends StatefulWidget {
  const HospitalProfilePage({super.key});

  @override
  State<HospitalProfilePage> createState() => _HospitalProfilePageState();
}

class _HospitalProfilePageState extends State<HospitalProfilePage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final inventoryViewModel = context.read<InventoryViewModel>();
    if (inventoryViewModel.nearbyFacilities.isEmpty) {
      await inventoryViewModel.fetchNearbyFacilities(role: UserRole.hospital);
    }
    if (mounted) {
      setState(() => _initialized = true);
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
        ),
      ),
    );
  }

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
      ],
    );
  }

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
      ],
    );
  }

  Widget _buildAboutHospitalCard(facility) {
    return _buildInfoCard(
      title: 'About Hospital',
      children: [
        Text(
          facility?.name != null
              ? '${facility!.name} provides comprehensive healthcare services including emergency care, surgery, and specialized treatments.'
              : 'Hospital information not available.',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

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
