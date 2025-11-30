import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/hospital/hospital_emergency_request_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_post_blood_request_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_requests_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_receive_donations_page.dart';
import 'package:jeevandhara/screens/hospital/hospital_donations_page.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  Map<String, int> _bloodStock = {};
  List<BloodRequest> _recentRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHospitalData();
  }

  Future<void> _fetchHospitalData() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch Stock
      final stockData = await ApiService().getHospitalStock(user.id!);
      final Map<String, int> stockMap = {};
      for (var item in stockData) {
        stockMap[item['bloodGroup']] = item['units'];
      }

      // Fetch Requests
      final requestData = await ApiService().getHospitalBloodRequests(user.id!);
      // Sort by date desc
      final requests = (requestData as List).map((e) => BloodRequest.fromJson(e)).toList();
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _bloodStock = stockMap;
          _recentRequests = requests.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching hospital data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _fetchHospitalData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHospitalHeader(),
                    const SizedBox(height: 24),
                    _buildQuickActionsList(context),
                    const SizedBox(height: 24),
                    _buildRecentRequests(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHospitalHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    final name = user?.hospital ?? user?.fullName ?? 'Hospital';
    final location = user?.hospitalLocation ?? user?.location ?? 'Unknown Location';

    return Container(
      width: double.infinity,
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
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Manage blood stock and requests efficiently', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildActionCard(
            context, 
            'Post Blood Request', 
            'Request specific blood types for patients', 
            Icons.add_circle_outline, 
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalPostBloodRequestPage()));
              _fetchHospitalData();
            }
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context, 
            'Emergency Alert', 
            'Broadcast critical blood needs immediately', 
            Icons.warning_amber_rounded, 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalEmergencyRequestPage()));
            }
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context, 
            'Receive Donations', 
            'Register new blood donation', 
            Icons.volunteer_activism, 
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalReceiveDonationsPage()));
              _fetchHospitalData();
            }
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context, 
            'Donation History', 
            'View received donations log', 
            Icons.history, 
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalDonationsPage()));
            }
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, {VoidCallback? onTap}) {
    const backgroundColor = Colors.white;
    const textColor = Colors.black87;
    const iconColor = Color(0xFFD32F2F);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 20),
          ],
        ),
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
            children: [
              const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)), 
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HospitalRequestsPage()));
                },
                child: const Text('Manage All')
              )
            ],
          ),
          if (_recentRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No recent requests.', style: TextStyle(color: Colors.grey)),
            ),
          ..._recentRequests.map((req) => _buildRequestCard(req)).toList(),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest req) {
    Color statusColor;
    IconData icon;
    
    switch (req.status) {
      case 'pending':
        statusColor = Colors.grey;
        icon = Icons.access_time;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        icon = Icons.check_circle_outline;
        break;
      case 'fulfilled':
        statusColor = const Color(0xFF4CAF50);
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        icon = Icons.info;
    }

    if (req.notifyViaEmergency) {
      statusColor = const Color(0xFFB71C1C);
      icon = Icons.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: statusColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Changed from req.patientName to explicit blood group text
                  Text('Blood Request: ${req.bloodGroup}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${req.units} Units Required', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(req.createdAt.toLocal().toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(req.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
