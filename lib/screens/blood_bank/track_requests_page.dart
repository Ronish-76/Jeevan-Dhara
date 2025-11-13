import 'package:flutter/material.dart';

class TrackRequestsPage extends StatefulWidget {
  const TrackRequestsPage({super.key});

  @override
  State<TrackRequestsPage> createState() => _TrackRequestsPageState();
}

class _TrackRequestsPageState extends State<TrackRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          tabs: const [
            Tab(text: 'All (10)'),
            Tab(text: 'Pending (4)'),
            Tab(text: 'Completed (6)'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatsOverview(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(status: null), // All
                _buildRequestsList(status: 'Pending'), // Pending
                _buildRequestsList(status: 'Completed'), // Completed
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '10', label: 'Total Requests', color: Color(0xFF2196F3)),
          _StatItem(value: '4', label: 'Active', color: Color(0xFFFF9800)),
          _StatItem(value: '3', label: 'Pending', color: Color(0xFFD32F2F)),
        ],
      ),
    );
  }

  Widget _buildRequestsList({String? status}) {
    final allRequests = [
      {'id': 'REC-2024-1001', 'hospital': 'Bir Hospital', 'blood': 'A+', 'units': 4, 'status': 'Pending'},
      {'id': 'REC-2024-1002', 'hospital': 'Patan Hospital', 'blood': 'O-', 'units': 2, 'status': 'Completed'},
      {'id': 'REC-2024-1003', 'hospital': 'Civil Hospital', 'blood': 'B+', 'units': 1, 'status': 'Completed'},
      {'id': 'REC-2024-1004', 'hospital': 'Manmohan Hospital', 'blood': 'AB+', 'units': 3, 'status': 'Pending'},
    ];

    final filtered = status == null ? allRequests : allRequests.where((req) => req['status'] == status).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildRequestCard(filtered[index]),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final statusMap = {
      'Pending': {'color': const Color(0xFFFF9800), 'action': 'Process'},
      'Completed': {'color': const Color(0xFF607D8B), 'action': 'View'},
    };

    final currentStatus = statusMap[request['status']]!;

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
                Text(request['id'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: (currentStatus['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(request['status'], style: TextStyle(color: currentStatus['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(request['hospital'], style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
                    children: [
                      TextSpan(text: '${request['units']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const TextSpan(text: ' Units of '),
                      TextSpan(text: request['blood'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentStatus['color'] as Color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(currentStatus['action'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
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
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
