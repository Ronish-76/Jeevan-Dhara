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
<<<<<<< HEAD
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
=======
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Urgent', 'Donors', 'Delivery'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: filter == 'All', // Static selection for UI
                      onSelected: (selected) {},
                      selectedColor: Colors.white,
                      labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(
            'Urgent Actions Needed',
            Icons.warning,
            color: const Color(0xFFD32F2F),
          ),
          _buildAlertCard(
            title: 'Request Expiring Soon',
            message:
                'Your O+ request expires in 2 hours. Consider extending it.',
            time: '15 min ago',
            priorityColor: const Color(0xFFD32F2F),
            action: 'Extend Request',
          ),
          _buildSectionHeader('Donor Responses', Icons.people_outline),
          _buildDonorResponseCard(),
          _buildSectionHeader(
            'Delivery Updates',
            Icons.local_shipping_outlined,
          ),
          _buildAlertCard(
            title: 'Delivery in Progress',
            message:
                'Emergency delivery REG-0044-FG7 started. ETA: 15 minutes.',
            time: '30 min ago',
            priorityColor: Colors.blue,
            action: 'Track Live',
          ),
          _buildSectionHeader('Recently Completed', Icons.check_circle_outline),
          _buildAlertCard(
            title: 'Request Fulfilled',
            message: 'Your O+ blood request was successfully fulfilled.',
            time: 'Yesterday',
            priorityColor: const Color(0xFF4CAF50),
          ),
        ],
>>>>>>> map-feature
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
>>>>>>> map-feature
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required String time,
    required Color priorityColor,
    String? action,
  }) {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (action != null)
              TextButton(
                onPressed: () {},
                child: Text(
                  action,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  Widget _buildDonorResponseCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFFF9800), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFD32F2F),
                  child: Text('RT', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rajesh Thapa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'O+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '2.3 km away',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Color(0xFF4CAF50)),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Contact',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('View Profile')),
              ],
            ),
          ],
        ),
      ),
    );
  }
>>>>>>> map-feature
}
