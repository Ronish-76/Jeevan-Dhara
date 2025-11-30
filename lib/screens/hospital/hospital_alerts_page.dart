import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/hospital/hospital_request_details_page.dart';

class HospitalAlertsPage extends StatefulWidget {
  const HospitalAlertsPage({super.key});

  @override
  State<HospitalAlertsPage> createState() => _HospitalAlertsPageState();
}

class _HospitalAlertsPageState extends State<HospitalAlertsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _inProcessRequests = [];
  List<Map<String, dynamic>> _completedRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Fetch Requests only
      final requestData = await ApiService().getHospitalBloodRequests(user.id!);
      final requests = (requestData as List).map((e) => BloodRequest.fromJson(e)).toList();

      _processRequests(requests);

    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processRequests(List<BloodRequest> requests) {
    final List<Map<String, dynamic>> inProcess = [];
    final List<Map<String, dynamic>> completed = [];

    // Sort by latest first
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (var req in requests) {
      final status = req.status.toLowerCase();
      
      if (status == 'fulfilled') {
        completed.add({
          'title': 'Request Completed',
          'message': '${req.units} units of ${req.bloodGroup} - Fulfilled',
          'time': _formatTimeAgo(req.createdAt),
          'color': Colors.green,
          'action': 'View',
          'request': req,
        });
      } else if (status == 'cancelled') {
         // Optionally include cancelled in completed or separate
         completed.add({
          'title': 'Request Cancelled',
          'message': '${req.units} units of ${req.bloodGroup} - Cancelled',
          'time': _formatTimeAgo(req.createdAt),
          'color': Colors.grey,
          'action': 'View',
          'request': req,
        });
      } else {
        // Pending, Accepted, Approved, In Transit -> In Process
        Color color = Colors.orange;
        String title = 'Request Pending';
        
        if (status == 'accepted' || status == 'approved') {
          color = Colors.blue;
          title = 'Request Accepted';
        } else if (status == 'in_transit') { // If status supports this
          color = Colors.purple;
          title = 'In Transit';
        }

        inProcess.add({
          'title': title,
          'message': '${req.units} units of ${req.bloodGroup} - ${status.toUpperCase()}',
          'time': _formatTimeAgo(req.createdAt),
          'color': color,
          'action': 'Track',
          'request': req,
        });
      }
    }

    _inProcessRequests = inProcess;
    _completedRequests = completed;
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Request Updates'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAlerts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _inProcessRequests.isEmpty && _completedRequests.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 500,
                        child: Center(child: Text('No request updates', style: TextStyle(color: Colors.grey))),
                      )
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_inProcessRequests.isNotEmpty) ...[
                        _buildSectionHeader('Request Process', Icons.sync, Colors.blue),
                        ..._inProcessRequests.map((a) => _buildAlertCard(a)),
                        const SizedBox(height: 16),
                      ],
                      if (_completedRequests.isNotEmpty) ...[
                        _buildSectionHeader('Request Completed', Icons.check_circle_outline, Colors.green),
                         ..._completedRequests.map((a) => _buildAlertCard(a)),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final priorityColor = alert['color'] as Color;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: priorityColor.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () {
          if (alert['request'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HospitalRequestDetailsPage(request: alert['request']),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
           padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: priorityColor, width: 4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(alert['title'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: priorityColor)),
                    const SizedBox(height: 4),
                    Text(alert['message'], style: const TextStyle(color: Colors.black87, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(alert['time'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              if (alert['action'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(alert['action'], style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
