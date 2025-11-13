import 'package:flutter/material.dart';

class HospitalRequestsPage extends StatefulWidget {
  const HospitalRequestsPage({super.key});

  @override
  State<HospitalRequestsPage> createState() => _HospitalRequestsPageState();
}

class _HospitalRequestsPageState extends State<HospitalRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180), // Increased height for stats and tabs
          child: Column(
            children: [
              _buildSearchBar(),
              _buildRequestStats(),
              _buildFilterTabs(),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(), // All
          _buildRequestsList(status: 'Pending'), // Pending
          _buildRequestsList(status: 'Fulfilled'), // Completed
          _buildRequestsList(status: 'Cancelled'), // Cancelled
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by blood type, donor...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildRequestStats() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _StatCard(value: '10', label: 'All', color: Color(0xFF2196F3))),
          SizedBox(width: 12),
          Expanded(child: _StatCard(value: '3', label: 'Pending', color: Color(0xFFFF9800))),
          SizedBox(width: 12),
          Expanded(child: _StatCard(value: '5', label: 'Completed', color: Color(0xFF4CAF50))),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      tabs: const [
        Tab(text: 'All (10)'),
        Tab(text: 'Pending (3)'),
        Tab(text: 'Completed (5)'),
        Tab(text: 'Cancelled (2)'),
      ],
    );
  }

  Widget _buildRequestsList({String? status}) {
    // Dummy data
    final requests = [
      {'blood': 'A+', 'units': 3, 'donor': 'Rajesh Kumar', 'requester': 'Dr. Sharma', 'status': 'Fulfilled'},
      {'blood': 'O-', 'units': 2, 'donor': 'Anjali Mehta', 'requester': 'Dr. Patel', 'status': 'Pending'},
      {'blood': 'B+', 'units': 1, 'donor': 'N/A', 'requester': 'Emergency Dept.', 'status': 'Cancelled'},
       {'blood': 'AB+', 'units': 4, 'donor': 'Sunita Rai', 'requester': 'Dr. Joshi', 'status': 'Fulfilled'},
    ];

    final filteredRequests = status == null ? requests : requests.where((r) => r['status'] == status).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(filteredRequests[index]);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final statusColors = {
      'Fulfilled': Colors.green,
      'Pending': Colors.orange,
      'Cancelled': Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              children: [
                Text('${request['units']} Units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
                  child: Text(request['blood'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request['donor'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Requested by: ${request['requester']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: 0.7, backgroundColor: Colors.grey.shade300, color: statusColors[request['status']]!)
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColors[request['status']]!.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(request['status'], style: TextStyle(color: statusColors[request['status']], fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
