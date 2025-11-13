import 'package:flutter/material.dart';

class DonorAlertsPage extends StatefulWidget {
  const DonorAlertsPage({super.key});

  @override
  State<DonorAlertsPage> createState() => _DonorAlertsPageState();
}

class _DonorAlertsPageState extends State<DonorAlertsPage> {
  bool _pushNotificationsEnabled = true;

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
        actions: [
          Switch(
            value: _pushNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _pushNotificationsEnabled = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationCard(
            icon: Icons.warning,
            title: 'Emergency Blood Request',
            message: 'Emergency O+ blood needed at Patan Hospital. Patient requires 2 units immediately.',
            time: '5 mins ago',
            priorityColor: const Color(0xFFD32F2F),
            actionText: 'View Details',
          ),
          _buildNotificationCard(
            icon: Icons.error,
            title: 'Critical Request Nearby',
            message: 'AB- blood urgently needed at Bir Hospital, Kathmandu. Distance: 2.5 km',
            time: '15 mins ago',
            priorityColor: const Color(0xFFFF9800),
            actionText: 'View Details',
          ),
          _buildNotificationCard(
            icon: Icons.check_circle,
            title: 'Donation Confirmed',
            message: 'Your blood donation at Bir Hospital has been successfully recorded. Thank you!',
            time: '2 hours ago',
            priorityColor: const Color(0xFF4CAF50),
          ),
          _buildNotificationCard(
            icon: Icons.calendar_today,
            title: 'Eligible to Donate',
            message: 'You\'re now eligible to donate blood again. Help save lives today!',
            time: '3 hours ago',
            priorityColor: const Color(0xFF4CAF50),
            actionText: 'Donate Now',
          ),
            _buildNotificationCard(
            icon: Icons.military_tech,
            title: 'Milestone Achieved!',
            message: 'Congratulations! You\'ve completed 10 donations. You\'re a true lifesaver!',
            time: '1 day ago',
            priorityColor: const Color(0xFFFFC107),
            actionText: 'Share',
          ),
        ],
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
            height: 90, // Adjust height to match card content
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
              onPressed: () {},
              child: Text(actionText, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
