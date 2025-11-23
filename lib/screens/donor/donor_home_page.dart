import 'package:flutter/material.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/screens/donor/donor_blood_bank_screen.dart';
import 'package:jeevandhara/screens/donor/donor_donation_history_page.dart';
import 'package:provider/provider.dart';

class DonorHomePage extends StatefulWidget {
  const DonorHomePage({super.key});

  @override
  State<DonorHomePage> createState() => _DonorHomePageState();
}

class _DonorHomePageState extends State<DonorHomePage> {
  late Future<List<BloodRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRequests();
  }

  void _refreshRequests() {
    setState(() {
      _requestsFuture = _fetchRequests();
    });
  }

  Future<List<BloodRequest>> _fetchRequests() async {
    try {
      final data = await ApiService().getAllBloodRequests();
      return (data as List).map((e) => BloodRequest.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching requests: $e');
      return [];
    }
  }

  Future<void> _handleAcceptRequest(String requestId) async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null) return;

      await ApiService().acceptBloodRequest(requestId, user.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Request accepted.')),
        );
        _refreshRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDonorHeader(context),
            _buildEligibilityBanner(context),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildUrgentRequestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorHeader(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Jeevan Dhara',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.bloodGroup ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, ${user?.fullName ?? 'Donor'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Thank you for being a lifesaver!',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEligibilityBanner(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    if (user?.lastDonationDate == null) return const SizedBox.shrink();

    final nextEligibleDate = user!.lastDonationDate!.add(
      const Duration(days: 90),
    );
    if (DateTime.now().isAfter(nextEligibleDate))
      return const SizedBox.shrink();

    final difference = nextEligibleDate.difference(DateTime.now());
    final daysRemaining = difference.inDays;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waiting Period Active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You can donate again in $daysRemaining days.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Blood Requests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionCard(
                Icons.home_work_outlined, 
                'Nearby Blood Banks',
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DonorBloodBankScreen()), 
                  );
                }
              ),
              _buildActionCard(
                Icons.history, 
                'Donation History',
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DonorDonationHistoryPage()), 
                  );
                }
              ),
              _buildActionCard(
                Icons.arrow_forward_ios,
                'View All',
                isOutlined: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label, {
    bool isOutlined = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isOutlined ? Colors.transparent : const Color(0xFFFFEBEE),
          child: Container(
            height: 100,
            decoration: isOutlined
                ? BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFD32F2F), size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrgentRequestsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Urgent Requests Nearby',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD32F2F),
                ),
              ),
              IconButton(onPressed: _refreshRequests, icon: const Icon(Icons.refresh, color: Color(0xFFD32F2F))),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<BloodRequest>>(
            future: _requestsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              
              final requests = snapshot.data;
              if (requests == null || requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('No urgent requests found nearby.')),
                );
              }

              // Filter only pending requests for urgent section
              final pendingRequests = requests.where((r) => r.status == 'pending').toList();

              if (pendingRequests.isEmpty) {
                 return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('No urgent requests found nearby.')),
                );
              }

              return Column(
                children: pendingRequests.map((request) => _buildRequestCard(request)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    final isUrgent = request.notifyViaEmergency;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD32F2F),
                  ),
                  child: Center(
                    child: Text(
                      request.bloodGroup,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              request.hospitalName,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? const Color(0xFFD32F2F)
                        : const Color(0xFFEF6C00), // Orange for standard
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUrgent ? 'Urgent' : 'Request',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleAcceptRequest(request.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('I Can Help'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
