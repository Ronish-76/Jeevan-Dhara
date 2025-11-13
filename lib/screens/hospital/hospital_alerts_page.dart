import 'package:flutter/material.dart';

class HospitalAlertsPage extends StatelessWidget {
  const HospitalAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Hospital Alerts'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.white)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Critical Alerts', Icons.warning_amber_rounded, Colors.red),
          _buildAlertCard(
            title: 'Critical Blood Shortage',
            message: 'O- blood stock at 2 units (min: 10 units required)',
            time: '15 minutes ago',
            priorityColor: Colors.red,
            actionText: 'Restock Now',
          ),
          _buildAlertCard(
            title: 'Emergency Blood Request',
            message: 'Cardiac surgery requires 4 units of AB+ immediately',
            time: '30 minutes ago',
            priorityColor: Colors.red,
            actionText: 'View Request',
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Inventory Warnings', Icons.inventory_2_outlined, Colors.orange),
          _buildAlertCard(
            title: 'Low Stock Warning',
            message: 'B+ stock low: 8 units (min: 15)',
            time: '2 hours ago',
            priorityColor: Colors.orange,
            actionText: 'Order',
          ),
          _buildAlertCard(
            title: 'A- Units Expiring',
            message: '3 units expire in 3 days',
            time: '4 hours ago',
            priorityColor: Colors.orange,
            actionText: 'Use First',
          ),
          const SizedBox(height: 16),
           _buildSectionHeader('Request Updates', Icons.person_outline, Colors.blue),
           _buildAlertCard(
            title: 'Donor Confirmed',
            message: 'Rajesh Kumar confirmed donation - ETA 45 minutes',
            time: '25 minutes ago',
            priorityColor: Colors.blue,
            actionText: 'Prepare',
          ),
        ],
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

  Widget _buildAlertCard({
    required String title,
    required String message,
    required String time,
    required Color priorityColor,
    String? actionText,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: priorityColor.withOpacity(0.5), width: 1),
      ),
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
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: priorityColor)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            if (actionText != null)
              TextButton(
                onPressed: () {},
                child: Text(actionText, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
