import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  String _selectedStatus = 'All';
  String _selectedTime = 'All Time';
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
              'Donation History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'All donor contributions',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildQuickStats(),
            const SizedBox(height: 16),
            _buildFilterControls(),
            const SizedBox(height: 16),
            _buildDonationsList(),
            const SizedBox(height: 16),
            _buildAnalyticsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final requests = bloodRequestViewModel.requests;
    final total = requests.length;
    final responded = requests.where((r) => r.status == 'responded').length;
    final pending = requests.where((r) => r.status == 'pending').length;
    final totalUnits = requests.fold<int>(0, (sum, req) => sum + req.units);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: total.toString(), label: 'Total Requests'),
        _StatItem(value: totalUnits.toString(), label: 'Total Units'),
        _StatItem(value: responded.toString(), label: 'Responded'),
        _StatItem(value: pending.toString(), label: 'Pending'),
      ],
    );
  }

  Widget _buildFilterControls() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Filter by Status'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['All', 'Pending', 'Responded', 'Cancelled']
                          .map(
                            (status) => ListTile(
                              title: Text(status),
                              onTap: () {
                                setState(() => _selectedStatus = status);
                                Navigator.pop(context);
                              },
                              trailing: _selectedStatus == status
                                  ? const Icon(Icons.check)
                                  : null,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    _selectedStatus,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            const VerticalDivider(),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Filter by Time'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['All Time', 'Last 7 Days', 'Last 30 Days']
                          .map(
                            (time) => ListTile(
                              title: Text(time),
                              onTap: () {
                                setState(() => _selectedTime = time);
                                Navigator.pop(context);
                              },
                              trailing: _selectedTime == time
                                  ? const Icon(Icons.check)
                                  : null,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    _selectedTime,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            const VerticalDivider(),
            const Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsList() {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    var requests = bloodRequestViewModel.requests;

    if (bloodRequestViewModel.isLoading && requests.isEmpty && !_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter by status
    if (_selectedStatus != 'All') {
      requests = requests
          .where((r) => r.status == _selectedStatus.toLowerCase())
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requests (${requests.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (requests.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No requests found')),
          )
        else
          ...requests.map((req) => _buildDonationCard(req)).toList(),
      ],
    );
  }

  Widget _buildDonationCard(request) {
    final statusColors = {
      'responded': Colors.green,
      'pending': Colors.orange,
      'cancelled': Colors.red,
    };
    final statusLabels = {
      'responded': 'Responded',
      'pending': 'Pending',
      'cancelled': 'Cancelled',
    };
    final color = statusColors[request.status] ?? Colors.grey;
    final statusLabel = statusLabels[request.status] ?? request.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Request ${request.id}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Requester: ${request.requesterName}'),
                  Text('Contact: ${request.requesterContact}'),
                  Text('Blood Type: ${request.bloodType}'),
                  Text('Units: ${request.units}'),
                  Text('Status: $statusLabel'),
                  if (request.notes != null) ...[
                    const SizedBox(height: 8),
                    Text('Notes: ${request.notes}'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Text(
                  request.requesterName.isNotEmpty
                      ? request.requesterName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      request.id,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.units} Unit(s), Blood Group: ${request.bloodType}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Card(
      elevation: 1,
      child: ExpansionTile(
        title: const Text(
          'Donation Analytics & Insights',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 2,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(child: Text('Monthly Trends Chart')),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '85%', label: 'Verification Rate'),
              _StatItem(value: '25%', label: 'Repeat Donors'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
