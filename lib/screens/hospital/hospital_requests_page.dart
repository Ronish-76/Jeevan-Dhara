import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/hospital/hospital_request_details_page.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
=======
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/blood_request_viewmodel.dart';
>>>>>>> map-feature

class HospitalRequestsPage extends StatefulWidget {
  const HospitalRequestsPage({super.key});

  @override
  State<HospitalRequestsPage> createState() => _HospitalRequestsPageState();
}

class _HospitalRequestsPageState extends State<HospitalRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
<<<<<<< HEAD
  List<BloodRequest> _allRequests = [];
  bool _isLoading = true;
=======
  String _searchQuery = '';
  final _searchController = TextEditingController();
>>>>>>> map-feature

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
<<<<<<< HEAD
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) return;

      final data = await ApiService().getHospitalBloodRequests(user.id!);
      final requests = (data as List).map((e) => BloodRequest.fromJson(e)).toList();
      
      // Sort by latest first
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _allRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
=======
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
>>>>>>> map-feature
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  List<BloodRequest> _filterRequests(String? status) {
    var filtered = _allRequests;
    if (status != null) {
      filtered = filtered.where((r) => r.status.toLowerCase() == status.toLowerCase()).toList();
    }
    return filtered;
=======
  Future<void> _loadData() async {
    await context.read<BloodRequestViewModel>().fetchActiveRequests(
      forceRefresh: true,
    );
>>>>>>> map-feature
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final allCount = _allRequests.length;
    final pendingCount = _allRequests.where((r) => r.status == 'pending').length;
    final fulfilledCount = _allRequests.where((r) => r.status == 'fulfilled').length;
    final cancelledCount = _allRequests.where((r) => r.status == 'cancelled').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request History'),
        bottom: PreferredSize(
<<<<<<< HEAD
          preferredSize: const Size.fromHeight(50), 
=======
          preferredSize: const Size.fromHeight(
            180,
          ), // Increased height for stats and tabs
>>>>>>> map-feature
          child: Column(
            children: [
              _buildFilterTabs(allCount, pendingCount, fulfilledCount, cancelledCount),
            ],
          ),
        ),
      ),
<<<<<<< HEAD
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(null), // All
              _buildRequestsList('pending'), // Pending
              _buildRequestsList('fulfilled'), // Completed
              _buildRequestsList('cancelled'), // Cancelled
            ],
          ),
    );
  }

  Widget _buildFilterTabs(int all, int pending, int fulfilled, int cancelled) {
=======
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildRequestsList(), // All
            _buildRequestsList(status: 'pending'), // Pending
            _buildRequestsList(status: 'responded'), // Completed
            _buildRequestsList(status: 'cancelled'), // Cancelled
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by blood type, requester...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestStats() {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final requests = bloodRequestViewModel.requests;
    final all = requests.length;
    final pending = requests.where((r) => r.status == 'pending').length;
    final completed = requests.where((r) => r.status == 'responded').length;
    final cancelled = requests.where((r) => r.status == 'cancelled').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _StatCard(
              value: all.toString(),
              label: 'All',
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: pending.toString(),
              label: 'Pending',
              color: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: completed.toString(),
              label: 'Completed',
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final requests = bloodRequestViewModel.requests;
    final all = requests.length;
    final pending = requests.where((r) => r.status == 'pending').length;
    final completed = requests.where((r) => r.status == 'responded').length;
    final cancelled = requests.where((r) => r.status == 'cancelled').length;

>>>>>>> map-feature
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      tabs: [
        Tab(text: 'All ($all)'),
        Tab(text: 'Pending ($pending)'),
<<<<<<< HEAD
        Tab(text: 'Completed ($fulfilled)'),
=======
        Tab(text: 'Completed ($completed)'),
>>>>>>> map-feature
        Tab(text: 'Cancelled ($cancelled)'),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildRequestsList(String? status) {
    final requests = _filterRequests(status);

    if (requests.isEmpty) {
      return const Center(child: Text('No requests found'));
=======
  Widget _buildRequestsList({String? status}) {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    var requests = bloodRequestViewModel.requests;

    if (bloodRequestViewModel.isLoading && requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filter by status
    if (status != null) {
      requests = requests.where((r) => r.status == status).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      requests = requests
          .where(
            (r) =>
                r.bloodType.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                r.requesterName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (r.requesterContact.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                )),
          )
          .toList();
    }

    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              status != null ? 'No ${status} requests' : 'No requests found',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
>>>>>>> map-feature
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(requests[index]);
      },
    );
  }

<<<<<<< HEAD
  Widget _buildRequestCard(BloodRequest request) {
    final statusColors = {
      'fulfilled': Colors.green,
      'pending': Colors.orange,
      'cancelled': Colors.grey,
      'approved': Colors.blue,
=======
  Widget _buildRequestCard(BloodRequestModel request) {
    final statusColors = {
      'responded': Colors.green,
      'pending': Colors.orange,
      'cancelled': Colors.grey,
>>>>>>> map-feature
    };
    final statusLabels = {
      'responded': 'Completed',
      'pending': 'Pending',
      'cancelled': 'Cancelled',
    };
    final statusColor = statusColors[request.status] ?? Colors.grey;
    final statusLabel = statusLabels[request.status] ?? request.status;

    Color statusColor = statusColors[request.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
<<<<<<< HEAD
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalRequestDetailsPage(request: request),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column(
                children: [
                  Text('${request.units} Units', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
                    child: Text(request.bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Blood Request: ${request.bloodGroup}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('Requested: ${request.createdAt.toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: request.status == 'fulfilled' ? 1.0 : (request.status == 'pending' ? 0.3 : 0.0), 
                      backgroundColor: Colors.grey.shade300, 
                      color: statusColor
                    )
                  ],
                ),
=======
          // Show request details
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Request Details'),
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
                  if (request.createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Created: ${_formatTimestamp(request.createdAt!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${request.units} Units',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      request.bloodType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact: ${request.requesterContact}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (request.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(request.createdAt!),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
>>>>>>> map-feature
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
<<<<<<< HEAD
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(request.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              )
=======
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
>>>>>>> map-feature
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
<<<<<<< HEAD
=======

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
>>>>>>> map-feature
