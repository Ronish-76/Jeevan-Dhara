import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/screens/blood_bank/analytics_reports_page.dart';
import 'package:jeevandhara/screens/blood_bank/donation_history_page.dart';
import 'package:jeevandhara/screens/blood_bank/manage_inventory_page.dart';
import 'package:jeevandhara/screens/blood_bank/receive_donations_page.dart';
import 'package:jeevandhara/screens/blood_bank/track_requests_page.dart'; // Still imported as it's used for Track Requests Card
import 'package:intl/intl.dart';

class BloodBankHomePage extends StatefulWidget {
  const BloodBankHomePage({super.key});

  @override
  State<BloodBankHomePage> createState() => _BloodBankHomePageState();
}

class _BloodBankHomePageState extends State<BloodBankHomePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  List<dynamic> _recentDonations = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      setState(() {
        _profileFuture = ApiService().getBloodBankProfile(user.id!).then((data) => data as Map<String, dynamic>);
      });
      await _fetchRecentDonations(user.id!);
    } else {
      setState(() {
        _profileFuture = Future.error('User not logged in');
      });
    }
  }

  Future<void> _fetchRecentDonations(String userId) async {
    try {
      final donations = await ApiService().getDonations(userId);
      if (mounted) {
        setState(() {
          _recentDonations = donations.take(5).toList(); // Take top 5
        });
      }
    } catch (e) {
      debugPrint('Error fetching donations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _refreshData,
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
                     child: Center(child: Text('Error loading profile: ${snapshot.error}')),
                   )
                 ],
               );
            }
            
            final profileData = snapshot.data;
            if (profileData == null) {
              return ListView(
                 physics: const AlwaysScrollableScrollPhysics(),
                 children: const [
                   SizedBox(
                     height: 500,
                     child: Center(child: Text('No profile data found')),
                   )
                 ],
               );
            }

            final inventory = Map<String, dynamic>.from(profileData['inventory'] ?? {});
            final name = profileData['bloodBankName'] ?? 'Blood Bank';
            final location = profileData['fullAddress'] ?? 'Location';

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(name, location),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 16),
                  _buildCriticalStockAlert(inventory),
                  const SizedBox(height: 16),
                  _buildInventorySection(inventory),
                  const SizedBox(height: 16),
                  _buildRecentDonations(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String location) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

   Widget _buildQuickActionsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildActionCard(context, 'Manage Inventory', 'Update stock levels', Icons.inventory_2_outlined, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageInventoryPage()));
          }),
          _buildActionCard(context, 'Receive Donations', 'Register new donations', Icons.bloodtype_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceiveDonationsPage()));
          }),
          // Donation History remains
          _buildActionCard(context, 'Donation History', 'View all donations', Icons.history, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationHistoryPage()));
          }),
          // Removed Distribute Blood, Added Track Requests
          _buildActionCard(context, 'Track Requests', 'Manage requests', Icons.list_alt, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackRequestsPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, {bool isPrimary = false, VoidCallback? onTap}) {
    final backgroundColor = isPrimary ? const Color(0xFFD32F2F) : const Color(0xFFFFEBEE);
    final textColor = isPrimary ? Colors.white : Colors.black87;
    final iconColor = isPrimary ? Colors.white : const Color(0xFFD32F2F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const Spacer(),
            Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalStockAlert(Map<String, dynamic> inventory) {
    int lowStockCount = 0;
    inventory.forEach((key, value) {
      if ((value as num) < 10) lowStockCount++;
    });

    if (lowStockCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text('$lowStockCount blood types are running low', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildInventorySection(Map<String, dynamic> inventory) {
    final allGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0),
      child: Column(
        children: [
           const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Current Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))], 
          ),
          const SizedBox(height: 12),
          if (inventory.isEmpty) 
             const Padding(padding: EdgeInsets.all(16), child: Text("No inventory data available")),
          
          if (inventory.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: allGroups.length,
            itemBuilder: (context, index) {
              final group = allGroups[index];
              final units = (inventory[group] ?? 0) as int;
              final color = units < 10 ? Colors.red : (units < 20 ? Colors.orange : Colors.green);
              return _buildInventoryCard(group, units, color);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(String group, int units, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(group, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('$units units', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color.withOpacity(0.9))),
        ],
      )
    );
  }

  Widget _buildRecentDonations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_recentDonations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("No recent donations", style: TextStyle(color: Colors.grey)),
            )
          else
            ..._recentDonations.map((d) => _buildDonationCard(d)).toList(),
        ],
      ),
    );
  }

  Widget _buildDonationCard(dynamic donation) {
    final name = donation['donorName'] ?? 'Unknown Donor';
    final bloodGroup = donation['bloodGroup'] ?? '';
    final dateStr = donation['donationDate'];
    String time = '';
    
    if (dateStr != null) {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (now.day == date.day && now.month == date.month && now.year == date.year) {
        time = 'Today, ${DateFormat('hh:mm a').format(date)}';
      } else {
        time = DateFormat('MMM dd, hh:mm a').format(date);
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      child: ListTile(
        leading: const Icon(Icons.person_outline, color: Color(0xFFD32F2F)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
          child: Text(bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
