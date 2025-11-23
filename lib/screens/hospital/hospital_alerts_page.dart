import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class HospitalAlertsPage extends StatefulWidget {
  const HospitalAlertsPage({super.key});

  @override
  State<HospitalAlertsPage> createState() => _HospitalAlertsPageState();
}

class _HospitalAlertsPageState extends State<HospitalAlertsPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
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
        title: const Text('Hospital Alerts'),
        actions: [
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

  Widget _buildAlertCard({
    required String title,
    required String message,
    required String time,
    required Color priorityColor,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: priorityColor.withOpacity(0.5), width: 1),
      ),
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
