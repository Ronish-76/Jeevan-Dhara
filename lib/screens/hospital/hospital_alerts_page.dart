import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/hospital/hospital_request_details_page.dart';

=======
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

>>>>>>> map-feature
class HospitalAlertsPage extends StatefulWidget {
  const HospitalAlertsPage({super.key});

  @override
  State<HospitalAlertsPage> createState() => _HospitalAlertsPageState();
}

class _HospitalAlertsPageState extends State<HospitalAlertsPage> {
<<<<<<< HEAD
  bool _isLoading = true;
  List<Map<String, dynamic>> _inProcessRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];
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

      // Fetch Requests only
      final requestData = await ApiService().getHospitalBloodRequests(user.id!);
      final requests = (requestData as List).map((e) => BloodRequest.fromJson(e)).toList();

      _processRequests(requests);

    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processRequests(List<BloodRequest> requests) {
    final List<Map<String, dynamic>> inProcess = [];
    final List<Map<String, dynamic>> completed = [];

    // Sort by latest first
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (var req in requests) {
      final status = req.status.toLowerCase();
      
      if (status == 'fulfilled') {
        completed.add({
          'title': 'Request Completed',
          'message': '${req.units} units of ${req.bloodGroup} - Fulfilled',
          'time': _formatTimeAgo(req.createdAt),
          'color': Colors.green,
          'action': 'View',
          'request': req,
        });
      } else if (status == 'cancelled') {
         // Optionally include cancelled in completed or separate
         completed.add({
          'title': 'Request Cancelled',
          'message': '${req.units} units of ${req.bloodGroup} - Cancelled',
          'time': _formatTimeAgo(req.createdAt),
          'color': Colors.grey,
          'action': 'View',
          'request': req,
        });
      } else {
        // Pending, Accepted, Approved, In Transit -> In Process
        Color color = Colors.orange;
        String title = 'Request Pending';
        
        if (status == 'accepted' || status == 'approved') {
          color = Colors.blue;
          title = 'Request Accepted';
        } else if (status == 'in_transit') { // If status supports this
          color = Colors.purple;
          title = 'In Transit';
        }

        inProcess.add({
          'title': title,
          'message': '${req.units} units of ${req.bloodGroup} - ${status.toUpperCase()}',
          'time': _formatTimeAgo(req.createdAt),
          'color': color,
          'action': 'Track',
          'request': req,
        });
      }
    }

    _inProcessRequests = inProcess;
    _completedRequests = completed;
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

=======
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final bloodRequestViewModel = context.read<BloodRequestViewModel>();
    final inventoryViewModel = context.read<InventoryViewModel>();
    await Future.wait([
      bloodRequestViewModel.fetchActiveRequests(forceRefresh: true),
      inventoryViewModel.fetchNearbyFacilities(role: UserRole.hospital),
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
    final inventoryWarnings = _buildInventoryWarnings(facility);
    final requestUpdates = _buildRequestUpdates(bloodRequestViewModel.requests);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request Updates'),
        actions: [
<<<<<<< HEAD
          IconButton(onPressed: _fetchAlerts, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inProcessRequests.isEmpty && _completedRequests.isEmpty
              ? const Center(child: Text('No request updates', style: TextStyle(color: Colors.grey)))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (_inProcessRequests.isNotEmpty) ...[
                      _buildSectionHeader('Request Process', Icons.sync, Colors.blue),
                      ..._inProcessRequests.map((a) => _buildAlertCard(a)),
                      const SizedBox(height: 16),
                    ],
                    if (_completedRequests.isNotEmpty) ...[
                      _buildSectionHeader('Request Completed', Icons.check_circle_outline, Colors.green),
                       ..._completedRequests.map((a) => _buildAlertCard(a)),
                    ],
                  ],
                ),
=======
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: _initialized && inventoryViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (criticalAlerts.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Critical Alerts',
                      Icons.warning_amber_rounded,
                      Colors.red,
                    ),
                    ...criticalAlerts,
                    const SizedBox(height: 16),
                  ],
                  if (inventoryWarnings.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Inventory Warnings',
                      Icons.inventory_2_outlined,
                      Colors.orange,
                    ),
                    ...inventoryWarnings,
                    const SizedBox(height: 16),
                  ],
                  if (requestUpdates.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Request Updates',
                      Icons.person_outline,
                      Colors.blue,
                    ),
                    ...requestUpdates,
                  ],
                  if (criticalAlerts.isEmpty &&
                      inventoryWarnings.isEmpty &&
                      requestUpdates.isEmpty)
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
            ),
>>>>>>> map-feature
    );
  }

  List<Widget> _buildCriticalAlerts(facility, BloodRequestViewModel bloodRequestViewModel) {
    final alerts = <Widget>[];

    // Critical stock alerts
    final criticalStock =
        facility?.inventory?.entries
            .where((entry) => entry.value < 5)
            .toList() ??
        [];
    for (final entry in criticalStock) {
      alerts.add(
        _buildAlertCard(
          title: 'Critical Blood Shortage',
          message:
              '${entry.key} blood stock at ${entry.value} units (min: 10 units required)',
          time: 'Just now',
          priorityColor: Colors.red,
          actionText: 'Restock Now',
          onAction: () {
            Navigator.pushNamed(context, '/hospital/manage-stock');
          },
        ),
      );
    }

    // Emergency requests
    final emergencyRequests = bloodRequestViewModel.requests
        .where((r) => r.status == 'pending')
        .take(2)
        .toList();
    for (final request in emergencyRequests) {
      alerts.add(
        _buildAlertCard(
          title: 'Emergency Blood Request',
          message:
              '${request.bloodType} - ${request.units} units needed by ${request.requesterName}',
          time: _formatTimestamp(request.createdAt),
          priorityColor: Colors.red,
          actionText: 'View Request',
          onAction: () {
            // Show request details
          },
        ),
      );
    }

    return alerts;
  }

  List<Widget> _buildInventoryWarnings(facility) {
    final warnings = <Widget>[];
    final lowStock =
        facility?.inventory?.entries
            .where((entry) => entry.value >= 5 && entry.value < 15)
            .toList() ??
        [];
    for (final entry in lowStock) {
      warnings.add(
        _buildAlertCard(
          title: 'Low Stock Warning',
          message: '${entry.key} stock low: ${entry.value} units (min: 15)',
          time: 'Recently',
          priorityColor: Colors.orange,
          actionText: 'Order',
          onAction: () {
            Navigator.pushNamed(context, '/hospital/manage-stock');
          },
        ),
      );
    }
    return warnings;
  }

  List<Widget> _buildRequestUpdates(List<BloodRequestModel> requests) {
    final updates = <Widget>[];
    final responded = requests
        .where((r) => r.status == 'responded')
        .take(3)
        .toList();
    for (final request in responded) {
      updates.add(
        _buildAlertCard(
          title: 'Request Fulfilled',
          message:
              '${request.bloodType} request by ${request.requesterName} has been responded to',
          time: _formatTimestamp(request.createdAt),
          priorityColor: Colors.blue,
          actionText: 'View',
          onAction: () {
            // Show request details
          },
        ),
      );
    }
    return updates;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown';
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hrs ago';
    return '${difference.inDays} days ago';
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final priorityColor = alert['color'] as Color;
=======
  Widget _buildAlertCard({
    required String title,
    required String message,
    required String time,
    required Color priorityColor,
    String? actionText,
    VoidCallback? onAction,
  }) {
>>>>>>> map-feature
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: priorityColor.withOpacity(0.5), width: 1),
      ),
<<<<<<< HEAD
      child: InkWell(
        onTap: () {
          if (alert['request'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HospitalRequestDetailsPage(request: alert['request']),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
           padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: priorityColor, width: 4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert['title'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: priorityColor)),
                    const SizedBox(height: 4),
                    Text(alert['message'], style: const TextStyle(color: Colors.black87, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(alert['time'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
=======
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: priorityColor, width: 4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: priorityColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (actionText != null)
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionText,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
>>>>>>> map-feature
                ),
              ),
              if (alert['action'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(alert['action'], style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
