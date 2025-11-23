import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:intl/intl.dart';

class RequesterAlertsScreen extends StatefulWidget {
  const RequesterAlertsScreen({super.key});

  @override
  State<RequesterAlertsScreen> createState() => _RequesterAlertsScreenState();
}

class _RequesterAlertsScreenState extends State<RequesterAlertsScreen> {
  late Future<List<dynamic>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      _alertsFuture = ApiService().getRequesterBloodRequests(user.id!);
    } else {
      _alertsFuture = Future.error('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('My Alerts'),
        actions: [IconButton(onPressed: () {
          setState(() {
            _loadAlerts();
          });
        }, icon: const Icon(Icons.refresh))],
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: FutureBuilder<List<dynamic>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading alerts: ${snapshot.error}'));
          }
          
          final requests = snapshot.data;
          if (requests == null || requests.isEmpty) {
            return const Center(child: Text('No alerts found'));
          }

          // Transform requests into alerts
          final alerts = _generateAlerts(requests);

          if (alerts.isEmpty) {
             return const Center(child: Text('No active alerts'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return alerts[index];
            },
          );
        },
      ),
    );
  }

  List<Widget> _generateAlerts(List<dynamic> requests) {
    List<Widget> alertWidgets = [];

    for (var request in requests) {
      final status = request['status'];
      final bloodGroup = request['bloodGroup'];
      final updatedAt = request['updatedAt'] != null ? DateTime.parse(request['updatedAt']) : DateTime.now();
      final timeAgo = _getTimeAgo(updatedAt);
      final donorName = (request['donor'] != null && request['donor'] is Map) 
          ? request['donor']['fullName'] 
          : 'a donor';

      if (status == 'pending') {
        alertWidgets.add(_buildAlertCard(
          title: 'Request In Process',
          message: 'Your $bloodGroup request is active. We are finding available donors.',
          time: timeAgo,
          priorityColor: Colors.blue,
        ));
      } else if (status == 'accepted') {
        alertWidgets.add(_buildAlertCard(
          title: 'Request Accepted',
          message: 'Your $bloodGroup request was accepted by $donorName.',
          time: timeAgo,
          priorityColor: const Color(0xFF4CAF50), // Green
          action: 'Contact Donor',
        ));
      } else if (status == 'cancelled') {
        alertWidgets.add(_buildAlertCard(
          title: 'Request Cancelled',
          message: 'Your $bloodGroup request was cancelled.',
          time: timeAgo,
          priorityColor: const Color(0xFFD32F2F), // Red
        ));
      } else if (status == 'fulfilled') {
        alertWidgets.add(_buildAlertCard(
          title: 'Request Fulfilled',
          message: 'Your $bloodGroup request was successfully fulfilled by $donorName.',
          time: timeAgo,
          priorityColor: const Color(0xFF2E7D32), // Dark Green
        ));
      }
    }
    return alertWidgets;
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  Widget _buildAlertCard({required String title, required String message, required String time, required Color priorityColor, String? action}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: priorityColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            if (action != null)
              TextButton(
                onPressed: () {},
                child: Text(action, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
