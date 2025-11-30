import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:jeevandhara/screens/blood_bank/distribute_blood_page.dart';

class TrackRequestsPage extends StatefulWidget {
  const TrackRequestsPage({super.key});

  @override
  State<TrackRequestsPage> createState() => _TrackRequestsPageState();
}

class _TrackRequestsPageState extends State<TrackRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _hospitalRequests = [];
  List<dynamic> _distributions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch Distributions (Completed)
      final distData = await ApiService().getDistributions(user.id!);
      
      // Fetch Blood Bank Requests (All/Pending)
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
            Text('Track Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Manage blood requests', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
            : Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCombinedList(), // All
                  _buildRequestsList(), // Pending (Hospital Requests)
                  _buildDistributionsList(), // Completed (Distributions)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCombinedList() {
    final combined = [..._hospitalRequests, ..._distributions];
    
    if (combined.isEmpty) return _buildEmptyState();

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
    
    if (pending.isEmpty) return _buildEmptyState('No pending requests');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildRequestCard(pending[index]),
    );
  }

  Widget _buildDistributionsList() {
    if (_distributions.isEmpty) return _buildEmptyState('No completed distributions');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _distributions.length,
      itemBuilder: (context, index) => _buildDistributionCard(_distributions[index]),
    );
  }

  Widget _buildEmptyState([String message = 'No records found']) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 400,
          child: Center(child: Text(message)),
        )
      ],
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
                            requestId: request['_id'],
                          ),
                        ),
                      ).then((_) => _refreshData()); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Process', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
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
