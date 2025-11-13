import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/hospital/hospital_emergency_request_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_find_donors_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_manage_stock_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_post_blood_request_page.dart';

class HospitalHomePage extends StatelessWidget {
  const HospitalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHospitalHeader(),
            const SizedBox(height: 24),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 12),
            _buildCriticalStockAlert(),
            const SizedBox(height: 12),
            _buildCurrentBloodStock(),
            const SizedBox(height: 24),
            _buildRecentRequests(),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalHeader() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jeevan Dhara - Hospital Portal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Bir Hospital', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              SizedBox(width: 4),
              Text('Kathmandu, Nepal', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Manage blood stock and requests efficiently', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
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
        childAspectRatio: 1.4,
        children: [
          _buildActionCard(context, 'Post Blood Request', 'Request specific blood types', Icons.add_circle_outline, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalPostBloodRequestPage()));
          }),
          _buildActionCard(context, 'Find Donors', 'Search nearby donors', Icons.search, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalFindDonorsPage()));
          }),
          _buildActionCard(context, 'Manage Blood Stock', 'Update available units', Icons.inventory_2_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalManageStockPage()));
          }),
          _buildActionCard(context, 'Emergency', 'Critical alerts', Icons.warning_amber_rounded, isPrimary: true, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalEmergencyRequestPage()));
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
          const Expanded(child: Text('2 blood types are at critical levels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () {}, child: const Text('View Critical', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)))
        ],
      ),
    );
  }

  Widget _buildCurrentBloodStock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Current Blood Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            children: [
              _buildStockCard('A+', 24, 'Adequate', Colors.green),
              _buildStockCard('B+', 18, 'Adequate', Colors.green),
              _buildStockCard('O-', 3, 'Low', Colors.orange),
              _buildStockCard('AB-', 1, 'Critical', Colors.red),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStockCard(String bloodGroup, int units, String status, Color statusColor) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bloodGroup, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: statusColor)),
          const Spacer(),
          Text('$units units', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), TextButton(onPressed: () {}, child: const Text('Manage All'))],
          ),
          _buildRequestCard('Nepal Red Cross', 'O- | 5 units', 'Urgent', 'Today, 10:30 AM', Icons.bloodtype, const Color(0xFFB71C1C)),
          _buildRequestCard('Rajesh Kumar', 'A+ | 1 unit', 'Fulfilled', 'Today, 8:15 AM', Icons.person_outline, const Color(0xFF4CAF50)),
          _buildRequestCard('Patan Hospital', 'B+ | 3 units', 'Pending', 'Yesterday', Icons.local_hospital_outlined, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildRequestCard(String requester, String info, String status, String time, IconData icon, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD32F2F)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(requester, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(info, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
