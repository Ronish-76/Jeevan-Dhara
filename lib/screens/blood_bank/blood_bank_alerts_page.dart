import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class BloodBankAlertsPage extends StatefulWidget {
  const BloodBankAlertsPage({super.key});

  @override
  State<BloodBankAlertsPage> createState() => _BloodBankAlertsPageState();
}

class _BloodBankAlertsPageState extends State<BloodBankAlertsPage> {
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
      inventoryViewModel.fetchNearbyFacilities(role: UserRole.bloodBank),
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
    required List<_AlertInfo> alerts,
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
          ...alerts.map((alert) => _buildAlertItem(alert, color)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertItem(_AlertInfo alert, Color priorityColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }
}

class _AlertInfo {
  final String title;
  final String description;
  final String time;
  _AlertInfo(this.title, this.description, this.time);
}
