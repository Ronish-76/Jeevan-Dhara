import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/hospital/hospital_request_details_page.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

class HospitalRequestsPage extends StatefulWidget {
  const HospitalRequestsPage({super.key});

  @override
  State<HospitalRequestsPage> createState() => _HospitalRequestsPageState();
}

class _HospitalRequestsPageState extends State<HospitalRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodRequest> _allRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        setState(() => _isLoading = false);
        return;
      }

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BloodRequest> _filterRequests(String filterType) {
    if (filterType == 'all') return _allRequests;
    
    return _allRequests.where((r) {
      final requestedFrom = r.requestedFrom?.toLowerCase();
      bool isDonorRequest = requestedFrom == null || requestedFrom == 'donor';
      
      if (filterType == 'donor') {
        return isDonorRequest;
      } else if (filterType == 'bloodbank') {
        return !isDonorRequest;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    final allCount = _allRequests.length;
    final donorCount = _allRequests.where((r) {
      final rf = r.requestedFrom?.toLowerCase();
      return rf == null || rf == 'donor';
    }).length;
    final bloodBankCount = allCount - donorCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50), 
          child: Column(
            children: [
              _buildFilterTabs(allCount, donorCount, bloodBankCount),
            ],
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList('all'), 
              _buildRequestsList('donor'), 
              _buildRequestsList('bloodbank'),
            ],
          ),
    );
  }

  Widget _buildFilterTabs(int all, int donor, int bloodBank) {
    return TabBar(
      controller: _tabController,
      isScrollable: false,
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      tabs: [
        Tab(text: 'All ($all)'),
        Tab(text: 'To Donors ($donor)'),
        Tab(text: 'To Blood Banks ($bloodBank)'),
      ],
    );
  }

  Widget _buildRequestsList(String filterType) {
    final requests = _filterRequests(filterType);

    return RefreshIndicator(
      onRefresh: _fetchRequests,
      child: requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 500,
                  child: Center(child: Text('No requests found')),
                )
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(requests[index]);
              },
            ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    final statusColors = {
      'fulfilled': Colors.green,
      'pending': Colors.orange,
      'cancelled': Colors.grey,
      'approved': Colors.blue,
    };

    Color statusColor = statusColors[request.status.toLowerCase()] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
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
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'To: ${request.requestedFrom == null || request.requestedFrom!.toLowerCase() == 'donor' ? 'Donor' : 'Blood Bank'}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(request.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
