// lib/screens/hospital/hospital_find_donors_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// FIX: Import the correct model for this page's purpose.
import '../../models/donor_model.dart';
// FIX: We no longer need BloodRequestModel or LocationModel here.
// import '../../models/blood_request_model.dart';
// import '../../models/location_model.dart';
import '../../viewmodels/donor_viewmodel.dart';
// We don't need InventoryViewModel for this simplified logic.
// import '../../viewmodels/inventory_viewmodel.dart';
import '../../widgets/empty_state_widget.dart'; // A reusable empty state widget is cleaner

class HospitalFindDonorsPage extends StatefulWidget {
  const HospitalFindDonorsPage({super.key});

  @override
  State<HospitalFindDonorsPage> createState() => _HospitalFindDonorsPageState();
}

class _HospitalFindDonorsPageState extends State<HospitalFindDonorsPage> {
  String _selectedBloodGroup = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use a listener for instant search feedback
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchQuery = _searchController.text);
      }
    });
    // Load the initial data when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // FIX: This method now correctly loads DONORS.
  Future<void> _loadData() async {
    // The complex logic with InventoryViewModel is removed for simplification.
    // We assume the view model can get the user's location itself if needed.
    await context.read<DonorViewModel>().loadNearbyDonors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Find Donors Nearby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildDonorsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name or location...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedBloodGroup == filter;
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                // FIX: Perform efficient client-side filtering. No need to call _loadData().
                setState(() {
                  _selectedBloodGroup = selected ? filter : 'All';
                });
              },
              selectedColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  // FIX: This method now filters a list of DonorModel.
  List<DonorModel> _getFilteredDonors(List<DonorModel> allDonors) {
    return allDonors.where((donor) {
      // Blood group filter logic
      final bloodGroupMatch = _selectedBloodGroup == 'All' ||
          donor.bloodGroup == _selectedBloodGroup;

      // Search query filter logic
      final searchMatch = _searchQuery.isEmpty ||
          donor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (donor.locationName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return bloodGroupMatch && searchMatch;
    }).toList();
  }

  // FIX: This widget now builds a list of DONORS.
  Widget _buildDonorsList() {
    final donorViewModel = context.watch<DonorViewModel>();
    // FIX: Get the correct list of donors from the view model.
    final filteredDonors = _getFilteredDonors(donorViewModel.nearbyDonors);

    if (donorViewModel.isLoading && donorViewModel.nearbyDonors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredDonors.isEmpty) {
      return const EmptyStateWidget( // A reusable empty state widget is cleaner
        icon: Icons.search_off,
        message: 'No available donors match your criteria.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: filteredDonors.length,
        itemBuilder: (context, index) {
          // FIX: Build a new card designed for donor info.
          return _buildDonorCard(filteredDonors[index]);
        },
      ),
    );
  }

  // FIX: A completely new card widget to display Donor information.
  Widget _buildDonorCard(DonorModel donor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Highlight available donors
        side: BorderSide(
          color: donor.isAvailable ? Colors.green : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Blood group circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD32F2F).withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  donor.bloodGroup,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Donor details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donor.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        // Display location name or distance if available
                        donor.locationName ?? (donor.distanceKm != null ? '~${donor.distanceKm!.toStringAsFixed(1)} km away' : 'Location unknown'),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (donor.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AVAILABLE FOR DONATION',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // You can add an action button or navigation arrow here
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
