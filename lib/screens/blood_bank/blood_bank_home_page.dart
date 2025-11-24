import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/screens/blood_bank/analytics_reports_page.dart';
import 'package:jeevandhara/screens/blood_bank/distribute_blood_page.dart';
import 'package:jeevandhara/screens/blood_bank/donation_history_page.dart';
import 'package:jeevandhara/screens/blood_bank/manage_inventory_page.dart';
import 'package:jeevandhara/screens/blood_bank/receive_donations_page.dart';
import 'package:jeevandhara/screens/blood_bank/track_requests_page.dart';
import 'package:intl/intl.dart';

class BloodBankHomePage extends StatefulWidget {
  const BloodBankHomePage({super.key});
=======

import '../../models/blood_request_model.dart';
import '../../models/location_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';
import '../map/map_screen.dart'; // Assuming a generic map screen exists
import 'analytics_reports_page.dart';
import 'distribute_blood_page.dart';
import 'donation_history_page.dart';
import 'manage_inventory_page.dart';
import 'receive_donations_page.dart';
import 'track_requests_page.dart';


class BloodBankHomePage extends StatefulWidget {
  // FIX 2: Add the User field. The other two fields are already correct.
  final User user;
  final String facilityId;
  final String facilityName;

  // FIX 3: Update the constructor to require all three parameters.
  const BloodBankHomePage({
    super.key,
    required this.user,
    required this.facilityId,
    required this.facilityName,
  });

  @override
  State<BloodBankHomePage> createState() => _BloodBankHomePageState();
}

class _BloodBankHomePageState extends State<BloodBankHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    // This logic is fine, but we can make it more specific.
    await Future.wait([
      context.read<BloodRequestViewModel>().fetchActiveRequests(forceRefresh: true),
      // Instead of fetching all nearby, you could fetch just this one facility's details
      // using context.read<InventoryViewModel>().fetchFacilityDetails(widget.facilityId);
      context.read<InventoryViewModel>().fetchNearbyFacilities(
        role: UserRole.bloodBank,
        radiusKm: 5,
      ),
    ]);
  }
>>>>>>> map-feature

  @override
  State<BloodBankHomePage> createState() => _BloodBankHomePageState();
}

class _BloodBankHomePageState extends State<BloodBankHomePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  List<dynamic> _recentDonations = [];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      _profileFuture = ApiService().getBloodBankProfile(user.id!).then((data) => data as Map<String, dynamic>);
      _fetchRecentDonations(user.id!);
    } else {
      _profileFuture = Future.error('User not logged in');
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
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final inventoryViewModel = context.watch<InventoryViewModel>();

    // This logic can be improved to find the specific facility.
    final facility = _selectFacility(inventoryViewModel);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
<<<<<<< HEAD
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }
          
          final profileData = snapshot.data;
          if (profileData == null) {
            return const Center(child: Text('No profile data found'));
          }

          final inventory = Map<String, dynamic>.from(profileData['inventory'] ?? {});
          final name = profileData['bloodBankName'] ?? 'Blood Bank';
          final location = profileData['fullAddress'] ?? 'Location';

          return SingleChildScrollView(
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
=======
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(facility),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 16),
              _buildCriticalStockAlert(facility, inventoryViewModel.isLoading),
              const SizedBox(height: 16),
              _buildInventorySection(facility, inventoryViewModel.isLoading),
              const SizedBox(height: 16),
              _buildRecentRequests(bloodRequestViewModel.requests),
            ],
          ),
        ),
>>>>>>> map-feature
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHeader(String name, String location) {
=======
  LocationModel? _selectFacility(InventoryViewModel provider) {
    if (provider.nearbyFacilities.isEmpty) return null;
    // A more robust way to find the current facility from the list.
    return provider.nearbyFacilities.firstWhere(
          (f) => f.id == widget.facilityId,
      orElse: () => provider.nearbyFacilities.first,
    );
  }

  Widget _buildHeader(LocationModel? facility) {
>>>>>>> map-feature
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
=======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                // Use the dynamic facility name passed to the widget.
                widget.facilityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Add a logout button for convenience
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthViewModel>().logout();
                },
              ),
            ],
          ),
>>>>>>> map-feature
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
<<<<<<< HEAD
              Text(location, style: const TextStyle(color: Colors.white70, fontSize: 14)),
=======
              Text(
                facility?.displayAddress ?? 'Loading address...',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
>>>>>>> map-feature
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    // This method is fine, though the navigation to MapScreen could be improved
    // to pass the specific facility details.
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
<<<<<<< HEAD
          _buildActionCard(context, 'Manage Inventory', 'Update stock levels', Icons.inventory_2_outlined, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageInventoryPage()));
          }),
          _buildActionCard(context, 'Receive Donations', 'Register new donations', Icons.bloodtype_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceiveDonationsPage()));
          }),
          _buildActionCard(context, 'Donation History', 'View all donations', Icons.history, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationHistoryPage()));
          }),
          _buildActionCard(context, 'Distribute Blood', 'Manage distributions', Icons.local_shipping_outlined, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DistributeBloodPage()));
          }),
=======
          _buildActionCard(
            context,
            'View Map',
            'Find hospitals & routes',
            Icons.map_outlined,
            isPrimary: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    role: UserRole.bloodBank,
                    // We can pass facility details to the map if MapScreen is updated to accept them
                  ),
                ),
              );
            },
          ),
          // ... other cards are fine
          _buildActionCard(
            context,
            'Manage Inventory',
            'Update stock levels',
            Icons.inventory_2_outlined,
            isPrimary: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageInventoryPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Receive Donations',
            'Register new donations',
            Icons.bloodtype_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceiveDonationsPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Track Requests',
            'Monitor requests',
            Icons.list_alt_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrackRequestsPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Distribute Blood',
            'Manage distributions',
            Icons.local_shipping_outlined,
            isPrimary: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DistributeBloodPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Analytics',
            'Reports & trends',
            Icons.analytics_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsReportsPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Donation History',
            'View donations',
            Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationHistoryPage(),
                ),
              );
            },
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }

  Widget _buildRecentRequests(List<BloodRequestModel> requests) {
    final pending = requests
        .where((req) => req.status == 'pending')
        .take(3)
        .toList();
    if (pending.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No pending requests at the moment.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incoming Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...pending.map(
                (request) => ListTile(
              leading: const Icon(
                Icons.local_hospital_outlined,
                color: Color(0xFFD32F2F),
              ),
              title: Text(request.requesterName),
              // FIX: Use the correct property name 'bloodGroup'.
              subtitle: Text('${request.bloodGroup} • ${request.units} units'),
              trailing: Text(_formatTimestamp(request.createdAt)),
            ),
          ),
        ],
      ),
    );
  }

  // --- No changes needed for the widgets below ---

  Widget _buildActionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon, {
        bool isPrimary = false,
        VoidCallback? onTap,
      }) {
    final backgroundColor = isPrimary
        ? const Color(0xFFD32F2F)
        : const Color(0xFFFFEBEE);
    final textColor = isPrimary ? Colors.white : Colors.black87;
    final iconColor = isPrimary ? Colors.white : const Color(0xFFD32F2F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildCriticalStockAlert(Map<String, dynamic> inventory) {
    int lowStockCount = 0;
    inventory.forEach((key, value) {
      if ((value as num) < 10) lowStockCount++;
    });

    if (lowStockCount == 0) return const SizedBox.shrink();
=======
  Widget _buildCriticalStockAlert(LocationModel? facility, bool isLoading) {
    final critical =
        facility?.inventory?.entries
            .where((entry) => entry.value < 5)
            .toList() ??
            [];
    if (isLoading && critical.isEmpty) {
      return const SizedBox.shrink();
    }
    if (critical.isEmpty) {
      return const SizedBox.shrink();
    }
>>>>>>> map-feature

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
<<<<<<< HEAD
          Expanded(child: Text('$lowStockCount blood types are running low', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          // Removed View Button
=======
          Expanded(
            child: Text(
              '${critical.length} blood types are running low',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'View',
              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildInventorySection(Map<String, dynamic> inventory) {
    final allGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    
=======
  Widget _buildInventorySection(LocationModel? facility, bool loading) {
    final inventory = facility?.inventory;
    if (loading && (inventory == null || inventory.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (inventory == null || inventory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Inventory data not available.'),
      );
    }

>>>>>>> map-feature
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
<<<<<<< HEAD
           const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Current Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))], // Removed View All button
=======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Inventory',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
>>>>>>> map-feature
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
<<<<<<< HEAD
              final group = allGroups[index];
              final units = (inventory[group] ?? 0) as int;
              final color = units < 10 ? Colors.red : (units < 20 ? Colors.orange : Colors.green);
              return _buildInventoryCard(group, units, color);
=======
              final entry = inventory.entries.elementAt(index);
              final color = _statusColor(entry.value);
              return _buildInventoryCard(entry.key, entry.value, color);
>>>>>>> map-feature
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
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            group,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
<<<<<<< HEAD
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
=======
          Text(
            '$units units',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Color _statusColor(int units) {
    if (units < 5) return Colors.red;
    if (units < 15) return Colors.orange;
    return Colors.green;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} d ago';
>>>>>>> map-feature
  }
}
