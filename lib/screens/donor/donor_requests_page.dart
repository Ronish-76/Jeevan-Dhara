import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
=======
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/donor_viewmodel.dart';
import 'donor_request_details_page.dart';
>>>>>>> map-feature

class DonorRequestsPage extends StatefulWidget {
  const DonorRequestsPage({super.key});

  @override
  State<DonorRequestsPage> createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage> {
  List<BloodRequest> _requests = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final userBloodGroup = user?.bloodGroup;

      final data = await ApiService().getAllBloodRequests();
      final allRequests = (data as List).map((json) => BloodRequest.fromJson(json)).toList();
      
      // Filter pending requests matching user's blood group
      final filtered = allRequests.where((r) {
        // Strict filtering as requested: "only show the blood requests of the blood type of users"
        bool matchGroup = userBloodGroup != null && r.bloodGroup == userBloodGroup;
        bool isPending = r.status == 'pending';
        return matchGroup && isPending;
      }).toList();

      setState(() {
        _requests = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getUrgencyColor(bool isEmergency) {
    return isEmergency ? const Color(0xFFB71C1C) : const Color(0xFF2196F3);
=======
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorViewModel>().loadUrgentRequests();
    });
>>>>>>> map-feature
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonorViewModel>();
    final requests = provider.urgentRequests.where((request) {
      if (_selectedBloodGroup == null) return true;
      return request.bloodType == _selectedBloodGroup;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Nearby Blood Requests'),
<<<<<<< HEAD
        // Removed search bar from bottom of AppBar
      ),
      body: Column(
        children: [
          // Removed _buildFilterChips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text('${_requests.length} requests matching your blood type', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : RefreshIndicator(
                        onRefresh: _fetchRequests,
                        child: _requests.isEmpty
                            ? const Center(child: Text('No matching requests found'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _requests.length,
                                itemBuilder: (context, index) {
                                  return _buildRequestCard(_requests[index]);
                                },
                              ),
                      ),
          ),
        ],
=======
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DonorViewModel>().loadUrgentRequests(
              bloodType: _selectedBloodGroup,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search by city or blood group',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DonorViewModel>().loadUrgentRequests(
          bloodType: _selectedBloodGroup,
        ),
        child: Column(
          children: [
            _buildFilterChips(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isLoading
                        ? 'Loading requests near you'
                        : '${requests.length} requests found near you',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && requests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : requests.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No requests at the moment. Pull to refresh.',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(requests[index]);
                      },
                    ),
            ),
          ],
        ),
>>>>>>> map-feature
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildRequestCard(BloodRequest request) {
    final urgencyColor = _getUrgencyColor(request.notifyViaEmergency);
=======
  Widget _buildFilterChips() {
    final bloodGroups = ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bloodGroups.length,
          itemBuilder: (context, index) {
            final group = bloodGroups[index];
            final isSelected = _selectedBloodGroup == group;
            return ChoiceChip(
              label: Text(group),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedBloodGroup = selected ? group : null;
                });
                context.read<DonorViewModel>().loadUrgentRequests(
                  bloodType: selected ? group : null,
                );
              },
              selectedColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: const Color(0xFFF0F0F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequestModel request) {
    final urgencyColor = request.urgency == 'critical'
        ? const Color(0xFFB71C1C)
        : const Color(0xFFD32F2F);
>>>>>>> map-feature
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonorRequestDetailsPage(request: request),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: urgencyColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
<<<<<<< HEAD
                decoration: BoxDecoration(shape: BoxShape.circle, color: urgencyColor.withOpacity(0.1)),
                child: Center(child: Text(request.bloodGroup, style: TextStyle(color: urgencyColor, fontSize: 18, fontWeight: FontWeight.bold))),
=======
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: urgencyColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    request.bloodType,
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
>>>>>>> map-feature
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(request.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), overflow: TextOverflow.ellipsis),
                        ),
                        if (request.notifyViaEmergency)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB71C1C),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EMERGENCY',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
=======
                    Text(
                      request.requesterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
>>>>>>> map-feature
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.locationName ?? 'Shared location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
<<<<<<< HEAD
                    Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(request.location, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(_getTimeAgo(request.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey))]),
=======
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.createdAt != null
                              ? request.createdAt!.toLocal().toString().split('.').first
                              : 'Date unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
>>>>>>> map-feature
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
<<<<<<< HEAD
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: request)),
=======
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonorRequestDetailsPage(request: request),
                    ),
>>>>>>> map-feature
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
<<<<<<< HEAD
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  elevation: 2,
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
=======
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('I Can Help', style: TextStyle(fontSize: 12)),
>>>>>>> map-feature
              ),
            ],
          ),
        ),
      ),
    );
  }
}
