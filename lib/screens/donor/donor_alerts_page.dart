import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';
import 'package:flutter_translate/flutter_translate.dart';

class DonorAlertsPage extends StatefulWidget {
  const DonorAlertsPage({super.key});

  @override
  State<DonorAlertsPage> createState() => _DonorAlertsPageState();
}

class _DonorAlertsPageState extends State<DonorAlertsPage> {
  late Future<Map<String, List<BloodRequest>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _refreshAlerts();
  }

  Future<void> _refreshAlerts() async {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  Future<Map<String, List<BloodRequest>>> _fetchData() async {
    try {
      final requestsData = await ApiService().getAllBloodRequests();
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      
      List<BloodRequest> history = [];
      if (user != null && user.id != null) {
        try {
           final historyData = await ApiService().getDonorDonationHistory(user.id!);
           history = (historyData as List).map((e) => BloodRequest.fromJson(e)).toList();
        } catch(e) {
           debugPrint('Error fetching history in alerts: $e');
        }
      }

      final requests = (requestsData as List).map((e) => BloodRequest.fromJson(e)).toList();
      
      return {
        'requests': requests,
        'history': history
      };
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void _addEligibilityAlert(User user, List<Widget> alerts) {
    if (user.isEligible) {
      alerts.add(_buildNotificationCard(
        icon: Icons.calendar_today,
        title: translate('eligible_to_donate'),
        message: translate('eligible_msg'),
        time: translate('just_now'),
        priorityColor: const Color(0xFF4CAF50),
      ));
    } else if (user.lastDonationDate != null) {
      final nextEligible = user.lastDonationDate!.add(const Duration(days: 90));
      final formattedDate = DateFormat('MMMM d, yyyy').format(nextEligible);
      alerts.add(_buildNotificationCard(
        icon: Icons.hourglass_bottom,
        title: translate('waiting_period'),
        message: translate('eligible_again_on', args: {'date': formattedDate}),
        time: translate('status'),
        priorityColor: Colors.orange,
      ));
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${translate('mins_ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${translate('hours_ago')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${translate('days_ago')}';
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
        title: Row(
          children: [
            const Icon(Icons.notifications_active_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(translate('alerts_notifications')),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshAlerts();
          await _dataFuture;
        },
        child: FutureBuilder<Map<String, List<BloodRequest>>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Wrap error in ListView so it's scrollable and refreshable
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  ),
                ],
              );
            }
            
            final user = Provider.of<AuthProvider>(context).user;
            if (user == null) {
               return ListView(
                 physics: const AlwaysScrollableScrollPhysics(),
                 children: [
                   SizedBox(
                     height: MediaQuery.of(context).size.height - 200,
                     child: Center(child: Text(translate('please_login_view_alerts'))),
                   ),
                 ],
               );
            }

            final requests = snapshot.data?['requests'] ?? [];
            final history = snapshot.data?['history'] ?? [];
            final List<Widget> alerts = [];

            // 1. Eligibility Alert
            _addEligibilityAlert(user, alerts);

            // 2. Emergency Requests
            final emergencyRequests = requests.where((r) => 
              r.status == 'pending' && 
              r.notifyViaEmergency && 
              r.bloodGroup == user.bloodGroup
            ).toList();

            for (var req in emergencyRequests) {
              alerts.add(_buildNotificationCard(
                icon: Icons.warning,
                title: translate('emergency_blood_request'),
                message: translate('urgent_blood_needed_msg', args: {'bloodGroup': req.bloodGroup, 'hospital': req.hospitalName, 'units': req.units}),
                time: _getTimeAgo(req.createdAt),
                priorityColor: const Color(0xFFD32F2F),
                actionText: translate('view_details'),
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: req)),
                  );
                },
              ));
            }

            // 3. Donation Confirmations
            final recentDonations = history.where((r) => r.status == 'fulfilled').take(5).toList();
            
            for (var donation in recentDonations) {
              alerts.add(_buildNotificationCard(
                icon: Icons.check_circle,
                title: translate('donation_confirmed'),
                message: translate('donation_confirmed_msg', args: {'hospital': donation.hospitalName}),
                time: _getTimeAgo(donation.createdAt),
                priorityColor: const Color(0xFF4CAF50),
              ));
            }

            if (alerts.isEmpty) {
              alerts.add(Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(translate('no_new_notifications')),
              )));
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: alerts,
            );
          },
        ),
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
