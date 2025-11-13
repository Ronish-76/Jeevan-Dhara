import 'package:flutter/material.dart';

class BloodBankAlertsPage extends StatelessWidget {
  const BloodBankAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildAlertsSection(
            title: 'Critical Alerts',
            icon: Icons.error,
            color: const Color(0xFFF44336),
            alerts: [
              _AlertInfo('Critical Low Stock', 'O- blood below 5 units. Emergency replenishment needed.', '5m ago'),
              _AlertInfo('Equipment Failure', 'Refrigerator Unit #3 temperature out of range.', '30m ago'),
            ],
          ),
          _buildAlertsSection(
            title: 'High Priority Alerts',
            icon: Icons.warning,
            color: const Color(0xFFFF9800),
            alerts: [
              _AlertInfo('Pending Verifications', '12 donations awaiting screening for over 4 hours.', '1h ago'),
              _AlertInfo('Expiry Warning', '20 units of A+ expiring in 48 hours.', '2h ago'),
            ],
          ),
           _buildAlertsSection(
            title: 'Informational',
            icon: Icons.info,
            color: const Color(0xFF2196F3),
            alerts: [
              _AlertInfo('New Donation', '1 unit of B+ received from donor DN-103.', '3h ago'),
              _AlertInfo('Distribution Completed', 'Order #HOS-543 delivered to Bir Hospital.', '4h ago'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_AlertInfo> alerts,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...alerts.map((alert) => _buildAlertItem(alert, color)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertItem(_AlertInfo alert, Color priorityColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(alert.description, style: const TextStyle(color: Colors.black87, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(alert.time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              const SizedBox(height: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
            ],
          )
        ],
      ),
    );
  }
}

class _AlertInfo {
  final String title;
  final String description;
  final String time;
  _AlertInfo(this.title, this.description, this.time);
}
