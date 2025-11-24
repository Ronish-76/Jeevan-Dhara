import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class AnalyticsReportsPage extends StatefulWidget {
  const AnalyticsReportsPage({super.key});

  @override
  State<AnalyticsReportsPage> createState() => _AnalyticsReportsPageState();
}

class _AnalyticsReportsPageState extends State<AnalyticsReportsPage> {
  String _selectedPeriod = 'Last 6 Months';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics & Reports',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Blood bank statistics',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: _selectedPeriod,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              dropdownColor: const Color(0xFFD32F2F),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              items: <String>['Last 6 Months', 'Last 30 Days', 'Last 7 Days']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedPeriod = newValue);
                }
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOverviewMetrics(bloodRequestViewModel, facility),
              const SizedBox(height: 20),
              _buildRealTimeAlerts(facility, bloodRequestViewModel),
              const SizedBox(height: 20),
              _buildChartsGrid(facility),
              const SizedBox(height: 20),
              _buildActionsPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics(BloodRequestViewModel bloodRequestViewModel, facility) {
    final requests = bloodRequestViewModel.requests;
    final totalRequests = requests.length;
    final inventory = facility?.inventory ?? {};
    final totalUnits = inventory.values.fold<int>(
      0,
      (sum, units) => sum + units,
    );
    final distributed = requests.where((r) => r.status == 'responded').length;
    final utilizationRate = totalRequests > 0
        ? (distributed / totalRequests * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MetricItem(
              value: totalRequests.toString(),
              label: 'Total Requests',
              trend: '+4.6%',
              trendColor: Colors.green,
            ),
            _MetricItem(
              value: distributed.toString(),
              label: 'Distributed',
              trend: '$utilizationRate% utilization',
              trendColor: Colors.blue,
            ),
            _MetricItem(
              value: totalUnits.toString(),
              label: 'Available',
              trend: 'Current stock',
              trendColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeAlerts(facility, BloodRequestViewModel bloodRequestViewModel) {
    final alerts = <Widget>[];
    final inventory = facility?.inventory ?? {};
    final lowStock = inventory.entries
        .where((e) => e.value < 10)
        .map((e) => e.key)
        .toList();
    if (lowStock.isNotEmpty) {
      alerts.add(
        _AlertItem(
          title: 'Low Stock Warning',
          message: '${lowStock.join(', ')} are below safety threshold.',
          color: Colors.orange,
        ),
      );
    }
    final critical = inventory.entries.where((e) => e.value < 5).length;
    if (critical > 0) {
      alerts.add(
        _AlertItem(
          title: 'Critical Stock Alert',
          message: '$critical blood type(s) at critical levels.',
          color: Colors.red,
        ),
      );
    }
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildSectionCard(
      title: 'Real-time & Predictive Analytics',
      child: Column(children: alerts),
    );
  }

  Widget _buildChartsGrid(facility) {
    final inventory = facility?.inventory ?? {};
    return Column(
      children: [
        _buildSectionCard(
          title: 'Monthly Requests & Distribution',
          child: AspectRatio(
            aspectRatio: 1.8,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Text('Bar & Line Chart Placeholder')),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Blood Units by Type',
          child: inventory.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No inventory data available')),
                )
              : AspectRatio(
                  aspectRatio: 1.8,
                  child: Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Text('Pie Chart Placeholder')),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionsPanel() {
    return _buildSectionCard(
      title: 'Insights & Actions',
      child: Column(
        children: [
          const Text(
            'Donation volumes show a positive trend over the last quarter, and distribution efficiency remains high.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text('Download Report (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value, label, trend;
  final Color trendColor;
  const _MetricItem({
    required this.value,
    required this.label,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          trend,
          style: TextStyle(
            color: trendColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title, message;
  final Color color;
  const _AlertItem({
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                Text(message, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
