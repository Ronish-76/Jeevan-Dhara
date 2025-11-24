<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/hospital/hospital_emergency_request_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_post_blood_request_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_requests_page.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});
=======
// lib/screens/hospital/hospital_home_page.dart

// FIX 1: Import Firebase Auth to recognize the User type
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeevandhara/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../models/location_model.dart'; // FIX 2: Make sure UserRole is available
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';
import '../map/hospital_request_map_screen.dart';
import 'hospital_emergency_request_page.dart';
import 'hospital_find_donors_page.dart';
import 'hospital_manage_stock_page.dart';
import 'hospital_post_blood_request_page.dart';

class HospitalHomePage extends StatefulWidget {
  // This constructor is now correct
  final User user;
  const HospitalHomePage({super.key, required this.user});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // FIX 3: The error is in this method.
  Future<void> _loadData() async {
    final bloodRequestViewModel = context.read<BloodRequestViewModel>();
    final inventoryViewModel = context.read<InventoryViewModel>();
    // Loading data in parallel is more efficient.
    await Future.wait([
      bloodRequestViewModel.fetchActiveRequests(forceRefresh: true),
      // FIX: Provide the required 'role' parameter here.
      inventoryViewModel.fetchNearbyFacilities(role: UserRole.hospital),
    ]);
  }
>>>>>>> map-feature

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  Map<String, int> _bloodStock = {};
  List<BloodRequest> _recentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHospitalData();
  }

  Future<void> _fetchHospitalData() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) return;

      // Fetch Stock
      final stockData = await ApiService().getHospitalStock(user.id!);
      final Map<String, int> stockMap = {};
      for (var item in stockData) {
        stockMap[item['bloodGroup']] = item['units'];
      }

      // Fetch Requests
      final requestData = await ApiService().getHospitalBloodRequests(user.id!);
      // Sort by date desc
      final requests = (requestData as List).map((e) => BloodRequest.fromJson(e)).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _bloodStock = stockMap;
          _recentRequests = requests.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching hospital data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final inventoryViewModel = context.watch<InventoryViewModel>();

    // This logic finds the most relevant facility from the fetched list.
    final facility = _selectFacility(inventoryViewModel);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
<<<<<<< HEAD
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHospitalHeader(),
                  const SizedBox(height: 24),
                  _buildQuickActionsList(context),
                  const SizedBox(height: 12),
                  _buildCriticalStockAlert(),
                  const SizedBox(height: 24),
                  _buildRecentRequests(),
                ],
              ),
            ),
    );
  }

  Widget _buildHospitalHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    final name = user?.hospital ?? user?.fullName ?? 'Hospital';
    final location = user?.hospitalLocation ?? user?.location ?? 'Unknown Location';

=======
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHospitalHeader(facility, widget.user),
              const SizedBox(height: 24),
              _buildQuickActionsGrid(context, facility),
              const SizedBox(height: 12),
              _buildCriticalStockAlert(facility, inventoryViewModel.isLoading),
              const SizedBox(height: 12),
              _buildCurrentBloodStock(facility, inventoryViewModel),
              const SizedBox(height: 24),
              _buildRecentRequests(
                bloodRequestViewModel.requests,
                bloodRequestViewModel.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LocationModel? _selectFacility(InventoryViewModel provider) {
    if (provider.nearbyFacilities.isEmpty) return null;
    // A better approach would be to find the facility associated with the user's ID
    return provider.nearbyFacilities.firstWhere(
          (f) => f.inventory != null && f.inventory!.isNotEmpty,
      orElse: () => provider.nearbyFacilities.first,
    );
  }

  Widget _buildHospitalHeader(LocationModel? facility, User user) {
>>>>>>> map-feature
    return Container(
      width: double.infinity,
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
          const Text('Jeevan Dhara - Hospital Portal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.white70, fontSize: 14)),
=======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jeevan Dhara - Hospital Portal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => context.read<AuthViewModel>().logout(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            facility?.name ?? user.displayName ?? 'Hospital',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                facility?.displayAddress ?? 'Loading location...',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
>>>>>>> map-feature
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Manage blood stock and requests efficiently',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildQuickActionsList(BuildContext context) {
=======
  Widget _buildQuickActionsGrid(BuildContext context, LocationModel? facility) {
>>>>>>> map-feature
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildActionCard(
<<<<<<< HEAD
            context, 
            'Post Blood Request', 
            'Request specific blood types for patients', 
            Icons.add_circle_outline, 
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalPostBloodRequestPage()));
              _fetchHospitalData();
            }
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context, 
            'Emergency Alert', 
            'Broadcast critical blood needs immediately', 
            Icons.warning_amber_rounded, 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalEmergencyRequestPage()));
            }
=======
            context,
            'View Map',
            'Find blood banks & routes',
            Icons.map_outlined,
            isPrimary: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HospitalRequestMapScreen(
                    facilityId: facility?.id ?? '',
                    facilityName: facility?.name ?? 'Hospital Map',
                  ),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Post Blood Request',
            'Request specific blood types',
            Icons.add_circle_outline,
            isPrimary: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalPostBloodRequestPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Find Donors',
            'Search nearby donors',
            Icons.search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalFindDonorsPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Manage Blood Stock',
            'Update available units',
            Icons.inventory_2_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalManageStockPage(),
                ),
              );
            },
          ),
          _buildActionCard(
            context,
            'Emergency',
            'Critical alerts',
            Icons.warning_amber_rounded,
            isPrimary: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HospitalEmergencyRequestPage(),
                ),
              );
            },
>>>>>>> map-feature
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    const backgroundColor = Colors.white;
    const textColor = Colors.black87;
    const iconColor = Color(0xFFD32F2F);
=======
  Widget _buildActionCard(
      BuildContext context,
      String title,
      String subtitle,
      IconData icon, {
        bool isPrimary = false,
        VoidCallback? onTap,
      }) {
    final backgroundColor = isPrimary ? const Color(0xFFD32F2F) : const Color(0xFFFFEBEE);
    final textColor = isPrimary ? Colors.white : Colors.black87;
    final iconColor = isPrimary ? Colors.white : const Color(0xFFD32F2F);
>>>>>>> map-feature

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildCriticalStockAlert() {
    int criticalCount = 0;
    _bloodStock.forEach((key, value) {
      if (value < 5) criticalCount++;
    });

    if (criticalCount == 0) return const SizedBox.shrink();

=======
  Widget _buildCriticalStockAlert(LocationModel? facility, bool inventoryLoading) {
    final lowInventory = facility?.inventory?.entries.where((entry) => entry.value < 5).toList() ?? [];
    if (inventoryLoading && (facility?.inventory == null)) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LinearProgressIndicator());
    }
    if (lowInventory.isEmpty) {
      return const SizedBox.shrink();
    }
>>>>>>> map-feature
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFB71C1C), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 24),
          const SizedBox(width: 12),
<<<<<<< HEAD
          Expanded(child: Text('$criticalCount blood types are at critical levels', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
=======
          Expanded(child: Text('${lowInventory.length} blood types are at critical levels', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () {}, child: Text('View Critical', style: TextStyle(color: Colors.white.withOpacity(0.9), decoration: TextDecoration.underline))),
        ],
      ),
    );
  }

  Widget _buildCurrentBloodStock(LocationModel? facility, InventoryViewModel provider) {
    final inventory = facility?.inventory;
    if (provider.isLoading && (inventory == null || inventory.isEmpty)) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24), child: Center(child: CircularProgressIndicator()));
    }
    if (inventory == null || inventory.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24), child: Text('No live inventory data yet. Connect to your facility to view stock.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Current Blood Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            children: inventory.entries.map((entry) => _buildStockCard(entry.key, entry.value, _statusColor(entry.value))).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(String bloodGroup, int units, Color statusColor) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bloodGroup, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
          const Spacer(),
          Text('$units units', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
>>>>>>> map-feature
        ],
      ),
    );
  }

  Widget _buildRecentRequests(List<BloodRequestModel> requests, bool isLoading) {
    final latestRequests = requests.take(3).toList();
    if (isLoading && latestRequests.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: CircularProgressIndicator());
    }
    if (latestRequests.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24), child: Text('No active requests yet.'));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
<<<<<<< HEAD
              const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), 
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalRequestsPage()));
                },
                child: const Text('Manage All')
              )
            ],
          ),
          if (_recentRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No recent requests.', style: TextStyle(color: Colors.grey)),
            ),
          ..._recentRequests.map((req) => _buildRequestCard(req)).toList(),
=======
              const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              TextButton(onPressed: () {}, child: const Text('Manage All')),
            ],
          ),
          ...latestRequests.map(_buildRequestCard),
>>>>>>> map-feature
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildRequestCard(BloodRequest req) {
    Color statusColor;
    IconData icon;
    
    switch (req.status) {
      case 'pending':
        statusColor = Colors.grey;
        icon = Icons.access_time;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case 'fulfilled':
        statusColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        icon = Icons.info;
    }

    if (req.notifyViaEmergency) {
      statusColor = const Color(0xFFB71C1C);
      icon = Icons.warning;
    }

=======
  Widget _buildRequestCard(BloodRequestModel request) {
    final statusColor = request.status == 'responded' ? const Color(0xFF4CAF50) : Colors.grey;
>>>>>>> map-feature
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
<<<<<<< HEAD
            Icon(icon, color: statusColor),
=======
            const Icon(Icons.bloodtype, color: Color(0xFFD32F2F)),
>>>>>>> map-feature
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
<<<<<<< HEAD
                  // Changed from req.patientName to explicit blood group text
                  Text('Blood Request: ${req.bloodGroup}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${req.units} Units Required', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(req.createdAt.toLocal().toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(req.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
=======
                  Text(request.requesterName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${request.bloodGroup} | ${request.units} units', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(request.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(_formatTimestamp(request.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
>>>>>>> map-feature
          ],
        ),
      ),
    );
  }

  String _statusLabel(int units) {
    if (units < 5) return 'Critical';
    if (units < 15) return 'Low';
    return 'Adequate';
  }

  Color _statusColor(int units) {
    if (units < 5) return Colors.red;
    if (units < 15) return Colors.orange;
    return Colors.green;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hrs ago';
    return '${difference.inDays} d ago';
  }
}
