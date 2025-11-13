import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/blood_bank/analytics_reports_page.dart';
import 'package:jeevandhara/screens/blood_bank/distribute_blood_page.dart';
import 'package:jeevandhara/screens/blood_bank/donation_history_page.dart';
import 'package:jeevandhara/screens/blood_bank/manage_inventory_page.dart';
import 'package:jeevandhara/screens/blood_bank/receive_donations_page.dart';
import 'package:jeevandhara/screens/blood_bank/track_requests_page.dart';

class BloodBankHomePage extends StatelessWidget {
  const BloodBankHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 16),
            _buildCriticalStockAlert(),
            const SizedBox(height: 16),
            _buildInventorySection(),
            const SizedBox(height: 16),
            _buildRecentDonations(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Central Blood Bank', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              SizedBox(width: 4),
              Text('Kathmandu, Nepal', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

   Widget _buildQuickActionsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildActionCard(context, 'Manage Inventory', 'Update stock levels', Icons.inventory_2_outlined, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageInventoryPage()));
          }),
          _buildActionCard(context, 'Receive Donations', 'Register new donations', Icons.bloodtype_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReceiveDonationsPage()));
          }),
          _buildActionCard(context, 'Track Requests', 'Monitor incoming requests', Icons.list_alt_outlined, onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const TrackRequestsPage()));
          }),
          _buildActionCard(context, 'Distribute Blood', 'Manage distributions', Icons.local_shipping_outlined, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DistributeBloodPage()));
          }),
           _buildActionCard(context, 'Analytics', 'View reports & trends', Icons.analytics_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsReportsPage()));
          }),
           _buildActionCard(context, 'Donation History', 'View all donations', Icons.history, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationHistoryPage()));
          }),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, {bool isPrimary = false, VoidCallback? onTap}) {
    final backgroundColor = isPrimary ? const Color(0xFFD32F2F) : const Color(0xFFFFEBEE);
    final textColor = isPrimary ? Colors.white : Colors.black87;
    final iconColor = isPrimary ? Colors.white : const Color(0xFFD32F2F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const Spacer(),
            Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalStockAlert() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(child: Text('4 blood types are running low', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () {}, child: const Text('View', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)))
        ],
      ),
    );
  }

  Widget _buildInventorySection() {
    final inventory = {'A+': 45, 'A-': 12, 'B+': 38, 'B-': 8, 'O+': 6, 'O-': 5, 'AB+': 4, 'AB-': 2};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('Current Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), TextButton(onPressed: () {}, child: const Text('View All'))],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final group = inventory.keys.elementAt(index);
              final units = inventory.values.elementAt(index);
              final color = units < 10 ? Colors.red : (units < 20 ? Colors.orange : Colors.green);
              return _buildInventoryCard(group, units, color);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(String group, int units, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(group, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text('$units units', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color.withOpacity(0.9))),
        ],
      )
    );
  }

  Widget _buildRecentDonations() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDonationCard('Rajesh Kumar', 'O+', 'Today, 8:30 AM'),
          _buildDonationCard('Sita Sharma', 'A+', 'Today, 10:15 AM'),
        ],
      ),
    );
  }

  Widget _buildDonationCard(String name, String bloodGroup, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      child: ListTile(
        leading: const Icon(Icons.person_outline, color: Color(0xFFD32F2F)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time, style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
          child: Text(bloodGroup, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}
