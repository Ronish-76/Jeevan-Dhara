import 'package:flutter/material.dart';

class RequesterProfileScreen extends StatelessWidget {
  const RequesterProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildRequestStatistics(),
            _buildInfoCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              details: {
                'Full Name': 'Ramesh Kumar',
                'Email': 'ramesh@teachinghospital.com',
                'Phone': '+977-98XXXXXXX',
                'Hospital Role': 'Emergency Department Coordinator',
              },
            ),
            _buildInfoCard(
              title: 'Hospital Contacts',
              icon: Icons.local_hospital_outlined,
              details: {
                'Primary Contact': 'Dr. Anjali Sharma - +977-98XXXXXXX',
                'Emergency Line': 'Hospital Emergency - +977-1-4412345',
                'Blood Bank Contact': 'Central Blood Bank - +977-1-4412303',
              },
            ),
            _buildRecentRequestHistory(),
            const SizedBox(height: 20),
            _buildQuickActionsFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 80, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Color(0xFFD32F2F)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ramesh Kumar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Requester',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildStatCard(
              '12',
              'Requests Made',
              Icons.add_alert_outlined,
              Colors.blue,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              '8',
              'Requests Fulfilled',
              Icons.check_circle_outline,
              Colors.green,
              subtitle: '67% success',
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              '2',
              'Active Now',
              Icons.hourglass_top_outlined,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Map<String, String> details,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFD32F2F)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...details.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Color(0xFF666666)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequestHistory() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFFD32F2F)),
                SizedBox(width: 8),
                Text(
                  'Recent Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildRequestItem(
              'O+ Request - Teaching Hospital',
              'Fulfilled',
              Colors.green,
            ),
            _buildRequestItem(
              'B- Request - Bir Hospital',
              'Active',
              Colors.orange,
            ),
            _buildRequestItem(
              'AB+ Request - Grande Hospital',
              'Expired',
              Colors.red,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'See All Requests (12)',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestItem(String title, String status, Color statusColor) {
    IconData icon = status == 'Fulfilled'
        ? Icons.check_circle
        : (status == 'Active' ? Icons.hourglass_bottom : Icons.cancel);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Emergency Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFD32F2F)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
