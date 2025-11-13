import 'package:flutter/material.dart';

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donation History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('All donor contributions', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildFilterControls(),
          const SizedBox(height: 16),
          _buildDonationsList(),
          const SizedBox(height: 16),
          _buildAnalyticsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: '12', label: 'Total Donations'),
        _StatItem(value: '12', label: 'Total Units'),
        _StatItem(value: '8', label: 'Verified'),
        _StatItem(value: '4', label: 'Pending'),
      ],
    );
  }

  Widget _buildFilterControls() {
    return const Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Status', style: TextStyle(fontWeight: FontWeight.w500)),
            Icon(Icons.arrow_drop_down),
            VerticalDivider(),
            Text('All Time', style: TextStyle(fontWeight: FontWeight.w500)),
            Icon(Icons.arrow_drop_down),
            VerticalDivider(),
            Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsList() {
    final donations = [
      {'name': 'Rajesh Kumar', 'id': 'DN-101', 'units': 1, 'blood': 'A+', 'status': 'Verified'},
      {'name': 'Sita Sharma', 'id': 'DN-102', 'units': 1, 'blood': 'O-', 'status': 'Pending'},
      {'name': 'Amit Thapa', 'id': 'DN-103', 'units': 1, 'blood': 'B+', 'status': 'Verified'},
      {'name': 'Anjali Mehta', 'id': 'DN-104', 'units': 1, 'blood': 'AB+', 'status': 'Rejected'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Donations (12)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...donations.map((d) => _buildDonationCard(d)).toList(),
      ],
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final statusColors = {
      'Verified': Colors.green,
      'Pending': Colors.orange,
      'Rejected': Colors.red,
    };
    final color = statusColors[donation['status']] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, child: Text(donation['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(donation['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(donation['id'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${donation['units']} Unit, Blood Group: ${donation['blood']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(donation['status'], style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildAnalyticsSection() {
    return Card(
      elevation: 1,
      child: ExpansionTile(
        title: const Text('Donation Analytics & Insights', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 2,
            child: Container(color: Colors.grey.shade200, child: const Center(child: Text('Monthly Trends Chart'))),
          ),
          const SizedBox(height: 12),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _StatItem(value: '85%', label: 'Verification Rate'), _StatItem(value: '25%', label: 'Repeat Donors'),]),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
