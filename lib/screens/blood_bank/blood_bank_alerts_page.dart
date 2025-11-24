import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:intl/intl.dart';

=======
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

>>>>>>> map-feature
class BloodBankAlertsPage extends StatefulWidget {
  const BloodBankAlertsPage({super.key});

  @override
  State<BloodBankAlertsPage> createState() => _BloodBankAlertsPageState();
}

class _BloodBankAlertsPageState extends State<BloodBankAlertsPage> {
<<<<<<< HEAD
  bool _isLoading = true;
  List<Map<String, dynamic>> _lowStockAlerts = [];
  List<Map<String, dynamic>> _requestAlerts = [];
  List<Map<String, dynamic>> _deliveryAlerts = [];
=======
  bool _initialized = false;
>>>>>>> map-feature

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) return;

      // 1. Fetch Inventory for Low Stock
      final profile = await ApiService().getBloodBankProfile(user.id!);
      final inventory = Map<String, dynamic>.from(profile['inventory'] ?? {});
      
      // 2. Fetch Requests
      final requests = await ApiService().getBloodBankRequests(user.id!);
      
      // 3. Fetch Distributions (Deliveries)
      final distributions = await ApiService().getDistributions(user.id!);

      _processData(inventory, requests, distributions);

    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processData(Map<String, dynamic> inventory, List<dynamic> requests, List<dynamic> distributions) {
    final List<Map<String, dynamic>> lowStock = [];
    final List<Map<String, dynamic>> reqAlerts = [];
    final List<Map<String, dynamic>> delAlerts = [];
    final now = DateTime.now();

    // Process Inventory
    inventory.forEach((group, units) {
      final count = (units as num).toInt();
      if (count < 5) {
        lowStock.add({
          'title': 'Critical Low Stock: $group',
          'description': 'Only $count units remaining. Immediate action required.',
          'time': 'Now',
          'priority': 'critical'
        });
      } else if (count < 10) {
        lowStock.add({
          'title': 'Low Stock Warning: $group',
          'description': '$count units remaining. Consider organizing a drive.',
          'time': 'Now',
          'priority': 'warning'
        });
      }
    });

    // Process Requests
    for (var req in requests) {
      if (req['status'] == 'pending') {
        final hospitalObj = req['hospital'];
        final hospitalName = hospitalObj is Map ? (hospitalObj['hospitalName'] ?? 'Unknown') : 'Unknown Hospital';
        final timeAgo = _formatTimeAgo(req['createdAt']);
        
        reqAlerts.add({
          'title': 'New Blood Request',
          'description': '$hospitalName requested ${req['unitsRequired'] ?? req['units']} units of ${req['bloodGroup']}.',
          'time': timeAgo,
        });
      }
    }

    // Process Distributions (Completed Deliveries)
    // Sort by latest first (already sorted by API but to be safe/flexible)
    // Take top 5 recent
    for (var dist in distributions.take(5)) {
      final hospitalName = dist['hospitalName'] ?? 'Unknown Hospital';
      final timeAgo = _formatTimeAgo(dist['dispatchDate']);
      
      delAlerts.add({
        'title': 'Delivery Completed',
        'description': '${dist['units']} units of ${dist['bloodGroup']} dispatched to $hospitalName.',
        'time': timeAgo,
      });
    }

    _lowStockAlerts = lowStock;
    _requestAlerts = reqAlerts;
    _deliveryAlerts = delAlerts;
  }

  String _formatTimeAgo(dynamic dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(date);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

=======
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final bloodRequestViewModel = context.read<BloodRequestViewModel>();
    final inventoryViewModel = context.read<InventoryViewModel>();
    await Future.wait([
      bloodRequestViewModel.fetchActiveRequests(forceRefresh: true),
      inventoryViewModel.fetchNearbyFacilities(role: UserRole.bloodBank),
    ]);
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

>>>>>>> map-feature
  @override
  Widget build(BuildContext context) {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;

    final criticalAlerts = _buildCriticalAlerts(facility, bloodRequestViewModel);
    final highPriority = _buildHighPriorityAlerts(facility);
    final informational = _buildInformationalAlerts(bloodRequestViewModel);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
<<<<<<< HEAD
          IconButton(onPressed: _fetchAlerts, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_lowStockAlerts.isNotEmpty)
                  _buildAlertsSection(
                    title: 'Inventory Alerts',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF44336),
                    alerts: _lowStockAlerts,
                  ),
                if (_requestAlerts.isNotEmpty)
                  _buildAlertsSection(
                    title: 'Pending Requests',
                    icon: Icons.assignment_late_outlined,
                    color: const Color(0xFFFF9800),
                    alerts: _requestAlerts,
                  ),
                if (_deliveryAlerts.isNotEmpty)
                  _buildAlertsSection(
                    title: 'Recent Deliveries',
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFF4CAF50),
                    alerts: _deliveryAlerts,
                  ),
                if (_lowStockAlerts.isEmpty && _requestAlerts.isEmpty && _deliveryAlerts.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text('No new alerts', style: TextStyle(color: Colors.grey)),
                  )),
              ],
=======
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _initialized && inventoryViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (criticalAlerts.isNotEmpty)
                    _buildAlertsSection(
                      title: 'Critical Alerts',
                      icon: Icons.error,
                      color: const Color(0xFFF44336),
                      alerts: criticalAlerts,
                    ),
                  if (highPriority.isNotEmpty)
                    _buildAlertsSection(
                      title: 'High Priority Alerts',
                      icon: Icons.warning,
                      color: const Color(0xFFFF9800),
                      alerts: highPriority,
                    ),
                  if (informational.isNotEmpty)
                    _buildAlertsSection(
                      title: 'Informational',
                      icon: Icons.info,
                      color: const Color(0xFF2196F3),
                      alerts: informational,
                    ),
                  if (criticalAlerts.isEmpty &&
                      highPriority.isEmpty &&
                      informational.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No alerts at this time',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
>>>>>>> map-feature
            ),
    );
  }

  List<_AlertInfo> _buildCriticalAlerts(facility, BloodRequestViewModel provider) {
    final alerts = <_AlertInfo>[];
    final criticalStock =
        facility?.inventory?.entries
            .where((entry) => entry.value < 5)
            .toList() ??
        [];
    for (final entry in criticalStock) {
      alerts.add(
        _AlertInfo(
          'Critical Low Stock',
          '${entry.key} blood below ${entry.value} units. Emergency replenishment needed.',
          'Just now',
        ),
      );
    }
    return alerts;
  }

  List<_AlertInfo> _buildHighPriorityAlerts(facility) {
    final alerts = <_AlertInfo>[];
    final lowStock =
        facility?.inventory?.entries
            .where((entry) => entry.value >= 5 && entry.value < 15)
            .toList() ??
        [];
    if (lowStock.isNotEmpty) {
      alerts.add(
        _AlertInfo(
          'Low Stock Warning',
          '${lowStock.length} blood type(s) below recommended levels.',
          'Recently',
        ),
      );
    }
    return alerts;
  }

  List<_AlertInfo> _buildInformationalAlerts(BloodRequestViewModel provider) {
    final alerts = <_AlertInfo>[];
    final pending = provider.requests
        .where((r) => r.status == 'pending')
        .length;
    if (pending > 0) {
      alerts.add(
        _AlertInfo(
          'Pending Requests',
          '$pending blood request(s) awaiting response.',
          'Recently',
        ),
      );
    }
    return alerts;
  }

  Widget _buildAlertsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> alerts,
  }) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...alerts.map((alert) => _buildAlertItem(alert)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
<<<<<<< HEAD
                Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(alert['description'], style: const TextStyle(color: Colors.black87, fontSize: 12)),
=======
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.description,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
>>>>>>> map-feature
              ],
            ),
          ),
          const SizedBox(width: 12),
<<<<<<< HEAD
          Text(alert['time'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
=======
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                alert.time,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }
}
