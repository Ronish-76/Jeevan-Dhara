import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';

class DonorAlertsPage extends StatefulWidget {
  const DonorAlertsPage({super.key});

  @override
  State<DonorAlertsPage> createState() => _DonorAlertsPageState();
}

class _DonorAlertsPageState extends State<DonorAlertsPage> {
  late Future<List<Widget>> _alertsFuture;

  @override
  void initState() {
    super.initState();
    _refreshAlerts();
  }

  void _refreshAlerts() {
    setState(() {
      _alertsFuture = _generateAlerts();
    });
  }

  Future<List<Widget>> _generateAlerts() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null || user.id == null) return [const Center(child: Text('Please log in to view alerts'))];

    final List<Widget> alerts = [];

    try {
      // 1. Eligibility Alert
      _addEligibilityAlert(user, alerts);

      // Fetch data in parallel
      final requestsData = await ApiService().getAllBloodRequests();
      final historyData = await ApiService().getDonorDonationHistory(user.id!);

      final requests = (requestsData as List).map((e) => BloodRequest.fromJson(e)).toList();
      final history = (historyData as List).map((e) => BloodRequest.fromJson(e)).toList();

      // 2. Emergency Requests (Pending, Emergency, Matching Blood Group)
      final emergencyRequests = requests.where((r) => 
        r.status == 'pending' && 
        r.notifyViaEmergency && 
        r.bloodGroup == user.bloodGroup
      ).toList();

      for (var req in emergencyRequests) {
        alerts.add(_buildNotificationCard(
          icon: Icons.warning,
          title: 'Emergency Blood Request',
          message: 'Urgent ${req.bloodGroup} blood needed at ${req.hospitalName}. Patient requires ${req.units} units.',
          time: _getTimeAgo(req.createdAt),
          priorityColor: const Color(0xFFD32F2F),
          actionText: 'View Details',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: req)),
            );
          },
        ));
      }

      // 3. Donation Confirmations (Fulfilled recently)
      // Filter recent fulfillments (e.g., last 7 days or just top 5)
      final recentDonations = history.where((r) => r.status == 'fulfilled').take(5).toList();
      
      for (var donation in recentDonations) {
        alerts.add(_buildNotificationCard(
          icon: Icons.check_circle,
          title: 'Donation Confirmed',
          message: 'Your blood donation at ${donation.hospitalName} has been successfully recorded. Thank you!',
          time: _getTimeAgo(donation.createdAt), // Ideally fulfilledAt, but createdAt used as proxy if needed
          priorityColor: const Color(0xFF4CAF50),
        ));
      }

      if (alerts.isEmpty) {
        alerts.add(const Center(child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No new notifications'),
        )));
      }

    } catch (e) {
      debugPrint('Error generating alerts: $e');
      alerts.add(Center(child: Text('Error loading alerts: $e')));
    }

    return alerts;
  }

  void _addEligibilityAlert(User user, List<Widget> alerts) {
    if (user.isEligible) {
      alerts.add(_buildNotificationCard(
        icon: Icons.calendar_today,
        title: 'Eligible to Donate',
        message: 'You are currently eligible to donate blood. Help save lives today!',
        time: 'Now',
        priorityColor: const Color(0xFF4CAF50),
      ));
    } else if (user.lastDonationDate != null) {
      final nextEligible = user.lastDonationDate!.add(const Duration(days: 90));
      final formattedDate = DateFormat('MMMM d, yyyy').format(nextEligible);
      alerts.add(_buildNotificationCard(
        icon: Icons.hourglass_bottom,
        title: 'Waiting Period',
        message: 'You will be eligible to donate again on $formattedDate.',
        time: 'Status',
        priorityColor: Colors.orange,
      ));
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text('Alerts & Notifications'),
          ],
        ),
        // Removed actions (Switch)
      ),
      body: FutureBuilder<List<Widget>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data ?? [],
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required Color priorityColor,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 100, // Fixed height for consistency
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: priorityColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: priorityColor)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction ?? () {},
              child: Text(actionText, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
