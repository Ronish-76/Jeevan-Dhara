import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:jeevandhara/screens/blood_bank/distribute_blood_page.dart';
=======
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/blood_request_viewmodel.dart';
>>>>>>> map-feature

class TrackRequestsPage extends StatefulWidget {
  const TrackRequestsPage({super.key});

  @override
  State<TrackRequestsPage> createState() => _TrackRequestsPageState();
}

class _TrackRequestsPageState extends State<TrackRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _hospitalRequests = [];
  List<dynamic> _distributions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
<<<<<<< HEAD
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) return;

      // Fetch Distributions (Completed)
      final distData = await ApiService().getDistributions(user.id!);
      
      // Fetch Blood Bank Requests (All/Pending)
      // Fetching requests specifically assigned to blood bank or open hospital requests
      final reqData = await ApiService().getBloodBankRequests(user.id!);
      
      if (mounted) {
        setState(() {
          _distributions = distData;
          _hospitalRequests = reqData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching track data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
=======
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    await context.read<BloodRequestViewModel>().fetchActiveRequests(
      forceRefresh: true,
    );
>>>>>>> map-feature
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _hospitalRequests.length + _distributions.length;
    final pendingCount = _hospitalRequests.where((r) => r['status'] != 'fulfilled' && r['status'] != 'cancelled').length;
    final completedCount = _distributions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Requests',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'Manage blood requests',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
<<<<<<< HEAD
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'All ($allCount)'),
            Tab(text: 'Pending ($pendingCount)'),
            Tab(text: 'Completed ($completedCount)'),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : Column(
        children: [
          _buildStatsOverview(allCount, pendingCount, completedCount),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCombinedList(), // All
                _buildRequestsList(), // Pending (Hospital Requests)
                _buildDistributionsList(), // Completed (Distributions)
              ],
=======
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer<BloodRequestViewModel>(
            builder: (context, BloodRequestViewModel, _) {
              final requests = BloodRequestViewModel.requests;
              final all = requests.length;
              final pending = requests.where((r) => r.status == 'pending').length;
              final completed = requests
                  .where((r) => r.status == 'responded')
                  .length;
              return TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                tabs: [
                  Tab(text: 'All ($all)'),
                  Tab(text: 'Pending ($pending)'),
                  Tab(text: 'Completed ($completed)'),
                ],
              );
            },
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            _buildStatsOverview(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestsList(status: null), // All
                  _buildRequestsList(status: 'pending'), // Pending
                  _buildRequestsList(status: 'responded'), // Completed
                ],
              ),
>>>>>>> map-feature
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildStatsOverview(int total, int active, int completed) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: total.toString(), label: 'Total Requests', color: const Color(0xFF2196F3)),
          _StatItem(value: active.toString(), label: 'Active', color: const Color(0xFFFF9800)),
          _StatItem(value: completed.toString(), label: 'Completed', color: const Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildCombinedList() {
    final combined = [..._hospitalRequests, ..._distributions];
    
    if (combined.isEmpty) return const Center(child: Text('No records found'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final item = combined[index];
        if (item.containsKey('dispatchDate')) {
          return _buildDistributionCard(item);
        } else {
          return _buildRequestCard(item);
        }
      },
    );
  }

  Widget _buildRequestsList() {
    final pending = _hospitalRequests.where((r) => r['status'] != 'fulfilled' && r['status'] != 'cancelled').toList();
    
    if (pending.isEmpty) return const Center(child: Text('No pending requests'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildRequestCard(pending[index]),
    );
  }

  Widget _buildDistributionsList() {
    if (_distributions.isEmpty) return const Center(child: Text('No completed distributions'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _distributions.length,
      itemBuilder: (context, index) => _buildDistributionCard(_distributions[index]),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final id = (request['_id'] as String).substring(0, 8).toUpperCase();
    final hospitalObj = request['hospital'];
    final hospitalName = hospitalObj is Map ? (hospitalObj['hospitalName'] ?? 'Unknown') : 'Unknown Hospital';
    final hospitalId = hospitalObj is Map ? (hospitalObj['_id'] ?? '') : (hospitalObj is String ? hospitalObj : '');
    
    final blood = request['bloodGroup'] ?? '';
    final units = request['unitsRequired'] ?? request['units'] ?? 0;
    final status = request['status'] ?? 'Pending';
    final isEmergency = request['notifyViaEmergency'] ?? false;
    
    final statusColor = status == 'pending' ? const Color(0xFFFF9800) : Colors.grey;
=======
  Widget _buildStatsOverview() {
    return Consumer<BloodRequestViewModel>(
      builder: (context, BloodRequestViewModel, _) {
        final requests = BloodRequestViewModel.requests;
        final total = requests.length;
        final active = requests.where((r) => r.status == 'pending').length;
        final pending = requests.where((r) => r.status == 'pending').length;
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                value: total.toString(),
                label: 'Total Requests',
                color: const Color(0xFF2196F3),
              ),
              _StatItem(
                value: active.toString(),
                label: 'Active',
                color: const Color(0xFFFF9800),
              ),
              _StatItem(
                value: pending.toString(),
                label: 'Pending',
                color: const Color(0xFFD32F2F),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsList({String? status}) {
    return Consumer<BloodRequestViewModel>(
      builder: (context, BloodRequestViewModel, _) {
        var requests = BloodRequestViewModel.requests;
        if (BloodRequestViewModel.isLoading && requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (status != null) {
          requests = requests.where((r) => r.status == status).toList();
        }
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  status != null
                      ? 'No ${status} requests'
                      : 'No requests found',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) => _buildRequestCard(requests[index]),
        );
      },
    );
  }

  Widget _buildRequestCard(BloodRequestModel request) {
    final statusMap = {
      'pending': {'color': const Color(0xFFFF9800), 'action': 'Process'},
      'responded': {'color': const Color(0xFF607D8B), 'action': 'View'},
    };
    final statusInfo =
        statusMap[request.status] ?? {'color': Colors.grey, 'action': 'View'};
    final statusColor = statusInfo['color'] as Color;
    final actionText = statusInfo['action'] as String;
>>>>>>> map-feature

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
<<<<<<< HEAD
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('REQ-$id', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    isEmergency ? 'EMERGENCY' : status.toString().toUpperCase(), 
                    style: TextStyle(color: isEmergency ? Colors.red : statusColor, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(hospitalName, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
                    children: [
                      TextSpan(text: '$units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const TextSpan(text: ' Units of '),
                      TextSpan(text: blood, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DistributeBloodPage(
                            prefilledHospitalId: hospitalId,
                            prefilledHospitalName: hospitalName,
                            prefilledBloodGroup: blood,
                            prefilledUnits: units,
                          ),
                        ),
                      ).then((_) => _fetchData()); // Refresh data when coming back
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Process', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
=======
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
                  Text('Status: ${request.status}'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    request.id,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
>>>>>>> map-feature
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.requesterName,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: '${request.units}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(text: ' Units of '),
                        TextSpan(
                          text: request.bloodType,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionCard(Map<String, dynamic> dist) {
    final id = (dist['_id'] as String).substring(0, 8).toUpperCase();
    final hospital = dist['hospitalName'] ?? 'Unknown Hospital';
    final blood = dist['bloodGroup'] ?? '';
    final units = dist['units'] ?? 0;
    final date = dist['dispatchDate'] != null ? DateFormat('MMM dd').format(DateTime.parse(dist['dispatchDate'])) : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DIST-$id', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('COMPLETED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(hospital, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
                    children: [
                      TextSpan(text: '$units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const TextSpan(text: ' Units of '),
                      TextSpan(text: blood, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
