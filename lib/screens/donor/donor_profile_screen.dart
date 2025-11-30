import 'package:flutter/material.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/location_picker_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class DonorProfileScreen extends StatefulWidget {
  final User donor;

  const DonorProfileScreen({super.key, required this.donor});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Use the provider user if updated, otherwise widget.donor
    final user = Provider.of<AuthProvider>(context).user ?? widget.donor;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => _showLanguageDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            _buildEligibilityBanner(user),
            _buildStatisticsSection(user),
            _buildInfoCard(
              title: translate('personal_information'),
              details: {
                translate('coordinates'): (user.latitude != null && user.longitude != null)
                    ? '${user.latitude!.toStringAsFixed(4)}, ${user.longitude!.toStringAsFixed(4)}'
                    : translate('not_set'),
                translate('age'): '${user.age} years',
                translate('contact'): user.phone ?? 'N/A',
                translate('email'): user.email ?? 'N/A',
                translate('address'): user.location ?? translate('add_location'),
              },
              icons: {
                translate('coordinates'): Icons.gps_fixed,
                translate('age'): Icons.person_outline,
                translate('contact'): Icons.phone_outlined,
                translate('email'): Icons.email_outlined,
                translate('address'): Icons.location_on_outlined,
              },
              onTapAction: {
                translate('address'): () => _updateLocation(context),
                translate('coordinates'): () => _updateLocation(context),
              }
            ),
            _buildInfoCard(
              title: translate('health_information'),
              details: {
                translate('blood_group'): user.bloodGroup ?? 'Unknown',
                translate('health_status'): 'Excellent', 
                translate('last_checkup'): 'N/A',
                translate('eligibility'): _getEligibilityText(user),
              },
               icons: {
                translate('blood_group'): Icons.bloodtype_outlined,
                translate('health_status'): Icons.health_and_safety_outlined,
                translate('last_checkup'): Icons.event_note_outlined,
                translate('eligibility'): Icons.medical_information_outlined,
              },
            ),
            _buildDonationHistory(),
            const SizedBox(height: 20),
            _buildActionButtons(context, user),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate('change_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(translate('english')),
              onTap: () {
                changeLocale(context, 'en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(translate('nepali')),
              onTap: () {
                changeLocale(context, 'ne');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLocation(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening map...'), duration: Duration(seconds: 1)),
    );
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerScreen(),
      ),
    );

    if (result != null && result is Map && mounted) {
      final address = result['address'] as String?;
      final latitude = result['latitude'] as double?;
      final longitude = result['longitude'] as double?;
      
      if (address != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final updateData = {
          'location': address,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        };
        
        try {
          final success = await authProvider.updateProfile(updateData);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location updated successfully')),
            );
          } else if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.errorMessage ?? 'Failed to update')),
            );
          }
        } catch (e) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    }
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
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
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 80, color: Color(0xFFD32F2F)),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName ?? 'Donor',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _updateLocation(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_location_alt, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        user.location ?? 'Set Location', 
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(user.totalDonations.toString(), 'Donations Made', Icons.bloodtype),
          _buildStatCard(user.totalDonations.toString(), 'Lives Saved', Icons.favorite), // Estimate 1 donation = 1 save
          _buildStatCard(_getLastDonationText(user), 'Last Donation', Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD32F2F), size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title, 
    required Map<String, String> details, 
    required Map<String, IconData> icons,
    Map<String, VoidCallback>? onTapAction,
  }) {
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
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...details.entries.map((entry) {
              final hasAction = onTapAction?.containsKey(entry.key) ?? false;
              return InkWell(
                onTap: hasAction ? onTapAction![entry.key] : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icons[entry.key], color: hasAction ? const Color(0xFFD32F2F) : Colors.grey, size: 20),
                      const SizedBox(width: 12),
                      Text('${entry.key}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                      Flexible(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: hasAction ? const Color(0xFFD32F2F) : const Color(0xFF666666),
                            fontWeight: hasAction ? FontWeight.w500 : FontWeight.normal,
                          ),
                          softWrap: true,
                        ),
                      ),
                      if (hasAction) 
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.edit, size: 14, color: Color(0xFFD32F2F)),
                        )
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

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
            Text(translate('recent_donations'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Center(child: Text("No donation history yet.", style: TextStyle(color: Colors.grey))),
            // We would fetch this from API if available
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateLocation(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
              ),
              child: Text(translate('update_location')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Toggle availability logic could go here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isAvailable ? const Color(0xFFD32F2F) : const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(user.isAvailable ? translate('go_offline') : translate('go_online'), style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  String _getLastDonationText(User user) {
    if (user.lastDonationDate == null) return 'Never';
    final difference = DateTime.now().difference(user.lastDonationDate!);
    final months = (difference.inDays / 30).floor();
    if (months < 1) return '${difference.inDays}d ago';
    return '${months}m ago';
  }

  Widget _buildEligibilityBanner(User user) {
    if (user.lastDonationDate == null) return const SizedBox.shrink();

    final nextEligibleDate = user.lastDonationDate!.add(const Duration(days: 90));
    if (DateTime.now().isAfter(nextEligibleDate)) return const SizedBox.shrink();

    final difference = nextEligibleDate.difference(DateTime.now());
    final daysRemaining = difference.inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waiting Period Active',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  'Eligible to donate in $daysRemaining days.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEligibilityText(User user) {
    if (user.lastDonationDate == null) return 'Eligible Now';
    final nextEligibleDate = user.lastDonationDate!.add(const Duration(days: 90));
    if (DateTime.now().isAfter(nextEligibleDate)) return 'Eligible Now';
    return 'Eligible after ${DateFormat('MMM d, y').format(nextEligibleDate)}';
  }
}
