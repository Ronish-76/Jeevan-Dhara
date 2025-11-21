import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/donor/donor_profile_screen.dart';

import 'package:jeevandhara/models/user_model.dart';

class FindDonorScreen extends StatefulWidget {
  const FindDonorScreen({super.key});

  @override
  State<FindDonorScreen> createState() => _FindDonorScreenState();
}

class _FindDonorScreenState extends State<FindDonorScreen> {
  // Sample data for donors
  final List<User> _donors = [
    User(
      fullName: 'Rajesh Thapa',
      bloodGroup: 'A+',
      location: 'Kathmandu',
      isAvailable: true,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 90)),
      totalDonations: 5,
    ),
    User(
      fullName: 'Sunita Sharma',
      bloodGroup: 'O+',
      location: 'Pokhara',
      isAvailable: false,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 30)),
      totalDonations: 2,
    ),
    User(
      fullName: 'Bikash Rai',
      bloodGroup: 'B-',
      location: 'Lalitpur',
      isAvailable: true,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 180)),
      totalDonations: 8,
    ),
    User(
      fullName: 'Anjali Gurung',
      bloodGroup: 'AB+',
      location: 'Kathmandu',
      isAvailable: true,
      lastDonationDate: DateTime.now().subtract(const Duration(days: 60)),
      totalDonations: 1,
    ),
  ];

  String _selectedFilter = 'A+';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Find Donors'),
            Text(
              '${_donors.length} donors found',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _donors.length,
              itemBuilder: (context, index) {
                return DonorCard(donor: _donors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFD32F2F),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Search by name, blood group, or location',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['A+', 'B+', 'O+', 'Nearby', 'Available Now'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;
            return FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: const Color(0xFFF0F0F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }
}

class DonorCard extends StatelessWidget {
  final User donor;
  const DonorCard({super.key, required this.donor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonorProfileScreen(donor: donor),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFFAFAFA),
        child: Opacity(
          opacity: donor.isAvailable ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                _buildMiddleSection(),
                _buildContactButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Color(0xFFFFEBEE),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          donor.bloodGroup ?? '?',
          style: const TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMiddleSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  donor.fullName ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: donor.isAvailable
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  donor.isAvailable ? 'Available' : 'Unavailable',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFD32F2F), size: 14),
              const SizedBox(width: 4),
              Text(
                donor.location ?? 'Unknown',
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Last donation: ${_getLastDonationText()} • ${donor.totalDonations} donations',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return ElevatedButton.icon(
      onPressed: donor.isAvailable ? () {} : null,
      icon: const Icon(Icons.phone, size: 16),
      label: const Text('Contact'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFD32F2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        disabledBackgroundColor: const Color(0xFFBDBDBD),
      ),
    );
  }

  String _getLastDonationText() {
    if (donor.lastDonationDate == null) return 'Never';
    final difference = DateTime.now().difference(donor.lastDonationDate!);
    final months = (difference.inDays / 30).floor();
    if (months < 1) return '${difference.inDays}d ago';
    return '${months}m ago';
  }
}
