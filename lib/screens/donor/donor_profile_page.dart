import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_translate/flutter_translate.dart';

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
    _refreshProfile();
  }

  void _refreshProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null && authProvider.user!.id != null) {
      setState(() {
        _profileDataFuture = _fetchProfileData(authProvider.user!.id!);
      });
    } else {
      setState(() {
        _profileDataFuture = Future.error('User not logged in');
      });
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
      DateTime? latestHistoryDate;

      for (var req in history) {
        if (req.status == 'fulfilled') {
           totalUnits += req.units;
           
           // Track latest donation date from history
           if (latestHistoryDate == null || req.createdAt.isAfter(latestHistoryDate)) {
             latestHistoryDate = req.createdAt;
           }
        }
      }

      // If backend totalDonations is 0 but history has fulfilled items, use history count
      int totalDonations = user.totalDonations;
      if (totalDonations == 0 && history.isNotEmpty) {
         totalDonations = history.where((r) => r.status == 'fulfilled').length;
      }
      
      // Determine effective last donation date
      DateTime? effectiveLastDonation = user.lastDonationDate;
      if (latestHistoryDate != null) {
        if (effectiveLastDonation == null || latestHistoryDate.isAfter(effectiveLastDonation)) {
          effectiveLastDonation = latestHistoryDate;
        }
      }

      return {
        'user': user,
        'totalUnits': totalUnits,
        'totalDonations': totalDonations,
        'effectiveLastDonation': effectiveLastDonation,
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
            tooltip: translate('logout'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshProfile();
          await _profileDataFuture;
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                ],
              );
            } else if (snapshot.hasData) {
              final user = snapshot.data!['user'] as User;
              final totalUnits = snapshot.data!['totalUnits'] as int;
              final totalDonations = snapshot.data!['totalDonations'] as int;
              final effectiveLastDonation = snapshot.data!['effectiveLastDonation'] as DateTime?;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    _buildDonationStatistics(totalDonations, totalUnits),
                    _buildEligibilityCard(effectiveLastDonation),
                    _buildInfoCard(user, effectiveLastDonation),
                    _buildSettingsCard(context),
                    _buildAccountManagementCard(context),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            } else {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(child: Text('No data found')),
                  )
                ],
              );
            }
          },
        ),
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
            '${translate('blood_group')}: ${donor.bloodGroup ?? 'N/A'}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationStatistics(int donations, int units) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStatCard(
            donations.toString(),
            translate('donations'),
            Icons.bloodtype_outlined,
          ),
          const SizedBox(width: 40),
          _buildStatCard(
            units.toString(),
            translate('units'),
            Icons.favorite_border,
          ),
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

  Widget _buildEligibilityCard(DateTime? lastDonationDate) {
    bool isEligible = true;
    int daysRemaining = 0;

    if (lastDonationDate != null) {
      final nextEligibleDate = lastDonationDate.add(const Duration(days: 90));
      final now = DateTime.now();
      if (now.isBefore(nextEligibleDate)) {
        daysRemaining = nextEligibleDate.difference(now).inDays;
        if (daysRemaining < 0) daysRemaining = 0;
        
        // If daysRemaining is 0 but still before (less than 24 hours), show 1 day or handle as ineligible
        if (daysRemaining == 0) daysRemaining = 1; 
        
        isEligible = false;
      }
    }

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
      child: Column(
        children: [
          Row(
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
                isEligible ? translate('eligible_to_donate') : translate('not_eligible_to_donate'),
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
          if (!isEligible && daysRemaining > 0) ...[
             const SizedBox(height: 8),
             Text(
               translate('eligible_in_days', args: {'days': daysRemaining}),
               style: const TextStyle(
                 color: Color(0xFFD32F2F),
                 fontSize: 14,
                 fontWeight: FontWeight.w500
               ),
             )
          ]
        ],
      ),
    );
  }

  Widget _buildInfoCard(User donor, DateTime? lastDonationDate) {
    return _buildSectionCard(
      title: translate('personal_information'),
      children: [
        _buildInfoRow(
          Icons.phone_outlined,
          translate('phone'),
          donor.phone ?? 'N/A',
        ),
        _buildInfoRow(Icons.email_outlined, translate('email'), donor.email ?? 'N/A'),
        _buildInfoRow(
          Icons.location_on_outlined,
          translate('location'),
          donor.location ?? 'N/A',
        ),
        _buildInfoRow(
          Icons.calendar_today_outlined,
          translate('last_donation'),
          lastDonationDate != null 
            ? DateFormat('MMM d, yyyy').format(lastDonationDate) 
            : 'N/A',
        ),
      ],
    );
  }
  
  Widget _buildSettingsCard(BuildContext context) {
    final currentLocale = LocalizedApp.of(context).delegate.currentLocale;
    final isNepali = currentLocale.languageCode == 'ne';

    return _buildSectionCard(
      title: translate('settings'), 
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.language, color: Colors.grey, size: 20),
              const SizedBox(width: 16),
              Text(translate('language'), style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              ToggleButtons(
                isSelected: [!isNepali, isNepali],
                onPressed: (int index) {
                   if (index == 0) {
                     changeLocale(context, 'en');
                   } else {
                     changeLocale(context, 'ne');
                   }
                },
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey,
                selectedColor: Colors.white,
                fillColor: const Color(0xFFD32F2F),
                constraints: const BoxConstraints(minHeight: 36, minWidth: 60),
                children: const [
                  Text('English', style: TextStyle(fontSize: 12)),
                  Text('नेपाली', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountManagementCard(BuildContext context) {
    return _buildSectionCard(
      title: translate('account_management'),
      children: [
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
            label: Text(
              translate('logout'),
              style: const TextStyle(
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
}
