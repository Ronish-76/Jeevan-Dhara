import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Nearby Blood Requests'),
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
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    final urgencyColor = _getUrgencyColor(request.notifyViaEmergency);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: request)),
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: urgencyColor.withOpacity(0.1)),
                child: Center(child: Text(request.bloodGroup, style: TextStyle(color: urgencyColor, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    ),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(request.hospitalName, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(request.location, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(_getTimeAgo(request.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: request)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  elevation: 2,
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
