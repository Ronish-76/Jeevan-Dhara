import 'package:flutter/material.dart';
import 'package:jeevandhara/models/donor_model.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/screens/requester/requester_donor_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RequesterFindDonorScreen extends StatefulWidget {
  const RequesterFindDonorScreen({super.key});

  @override
  State<RequesterFindDonorScreen> createState() =>
      _RequesterFindDonorScreenState();
}

class _RequesterFindDonorScreenState extends State<RequesterFindDonorScreen> {
  late Future<List<Donor>> _donorsFuture;
  String _selectedBloodGroup = 'All';

  @override
  void initState() {
    super.initState();
    _donorsFuture = _fetchDonors();
  }

  Future<List<Donor>> _fetchDonors() async {
    try {
      final donorsJson = await ApiService().getDonors();
      return donorsJson.map((json) => Donor.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching donors: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Find Donors', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<Donor>>(
              future: _donorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No donors found.'));
                }

                final allDonors = snapshot.data!;
                final filteredDonors = _selectedBloodGroup == 'All'
                    ? allDonors
                    : allDonors
                        .where((d) => d.bloodGroup == _selectedBloodGroup)
                        .toList();
                
                if (filteredDonors.isEmpty) {
                  return const Center(child: Text('No donors found for this blood group.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: filteredDonors.length,
                  itemBuilder: (context, index) {
                    return DonorCard(donor: filteredDonors[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final bloodGroups = [
      'All',
      'A+',
      'A-',
      'B+',
      'B-',
      'O+',
      'O-',
      'AB+',
      'AB-',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bloodGroups.length,
          itemBuilder: (context, index) {
            final group = bloodGroups[index];
            final isSelected = _selectedBloodGroup == group;
            return ChoiceChip(
              label: Text(group),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedBloodGroup = group;
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
  final Donor donor;
  const DonorCard({super.key, required this.donor});

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequesterDonorProfileScreen(donor: donor),
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
                _buildContactButton(context),
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
          donor.bloodGroup,
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
                  donor.name,
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
              Expanded(
                child: Text(
                  donor.location,
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Assuming these fields might not be in the immediate response or need to be calculated
          if (donor.totalDonations > 0)
            Text(
              '${donor.totalDonations} donations',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: (donor.isAvailable && donor.phone != null && donor.phone!.isNotEmpty) 
        ? () => _makePhoneCall(donor.phone!) 
        : null,
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
}
