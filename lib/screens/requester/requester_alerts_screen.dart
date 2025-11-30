import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_translate/flutter_translate.dart';

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

  Future<void> _loadAlerts() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      setState(() {
        _alertsFuture = ApiService().getRequesterBloodRequests(user.id!).then((data) {
          _checkAndNotify(data);
          return data;
        });
      });
    } else {
      setState(() {
        _alertsFuture = Future.error('User not logged in');
      });
    }
  }

  void _checkAndNotify(List<dynamic> requests) {
    if (requests.isNotEmpty) {
      // Just check the most recent request for updates
      // In a real app, we would store the last seen timestamp or ID to compare
      final latestRequest = requests.first;
      final status = latestRequest['status'];
      final updatedAt = latestRequest['updatedAt'] != null ? DateTime.parse(latestRequest['updatedAt']) : DateTime.now();
      
      // Only notify if updated recently (e.g., within last 5 minutes) to avoid spam on every load
      if (DateTime.now().difference(updatedAt).inMinutes < 5) {
        String title = '';
        String body = '';
        final bloodGroup = latestRequest['bloodGroup'];
        final donorName = (latestRequest['donor'] != null && latestRequest['donor'] is Map) 
            ? latestRequest['donor']['fullName'] 
            : 'a donor';

        if (status == 'accepted') {
          title = 'Request Accepted';
          body = 'Your $bloodGroup request was accepted by $donorName.';
        } else if (status == 'fulfilled') {
          title = 'Request Fulfilled';
          body = 'Your $bloodGroup request was fulfilled by $donorName.';
        } else if (status == 'cancelled') {
          title = 'Request Cancelled';
          body = 'Your $bloodGroup request was cancelled.';
        }

        if (title.isNotEmpty) {
          NotificationService.showNotification(
            id: latestRequest['_id'].hashCode, 
            title: title, 
            body: body
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Text(translate('notifications')),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        child: FutureBuilder<List<dynamic>>(
          future: _alertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(child: Text('Error loading alerts: ${snapshot.error}')),
                  ),
                ],
              );
            }
            
            final requests = snapshot.data;
            if (requests == null || requests.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(child: Text(translate('no_notifications'))),
                  ),
                ],
              );
            }

            // Transform requests into alerts
            final alerts = _generateAlerts(requests);

            if (alerts.isEmpty) {
               return ListView(
                 children: [
                   SizedBox(
                     height: MediaQuery.of(context).size.height - 200,
                     child: Center(child: Text(translate('no_notifications'))),
                   ),
                 ],
               );
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
          : translate('a_donor'); // 'a donor' needs to be in your translation if used

      if (status == 'pending') {
        alertWidgets.add(_buildAlertCard(
          title: translate('request_in_process'),
          message: translate('request_in_process_msg', args: {'bloodGroup': bloodGroup}),
          time: timeAgo,
          priorityColor: Colors.blue,
        ));
      } else if (status == 'accepted') {
        alertWidgets.add(_buildAlertCard(
          title: translate('request_accepted'),
          message: translate('request_accepted_msg', args: {'bloodGroup': bloodGroup, 'donorName': donorName}),
          time: timeAgo,
          priorityColor: const Color(0xFF4CAF50), // Green
          action: translate('contact_donor'),
        ));
      } else if (status == 'cancelled') {
        alertWidgets.add(_buildAlertCard(
          title: translate('request_cancelled'),
          message: translate('request_cancelled_msg', args: {'bloodGroup': bloodGroup}),
          time: timeAgo,
          priorityColor: const Color(0xFFD32F2F), // Red
        ));
      } else if (status == 'fulfilled') {
        alertWidgets.add(_buildAlertCard(
          title: translate('request_fulfilled'),
          message: translate('request_fulfilled_msg', args: {'bloodGroup': bloodGroup, 'donorName': donorName}),
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
      return '${difference.inMinutes} ${translate('mins_ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${translate('hours_ago')}';
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
