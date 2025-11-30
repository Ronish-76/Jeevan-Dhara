import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/requester/requester_blood_bank_screen.dart';
import 'package:jeevandhara/screens/requester/requester_find_donor_screen.dart';
import 'package:jeevandhara/screens/requester/requester_post_blood_request_screen.dart';
import 'package:jeevandhara/screens/requester/requester_my_requests_screen.dart';
import 'package:jeevandhara/screens/requester/requester_request_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:flutter_translate/flutter_translate.dart';

class RequesterHomePage extends StatefulWidget {
  const RequesterHomePage({super.key});

  @override
  State<RequesterHomePage> createState() => _RequesterHomePageState();
}

class _RequesterHomePageState extends State<RequesterHomePage> {
  
  Future<void> _refreshRequests() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: _refreshRequests,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildFeatureGrid(),
              const SizedBox(height: 20),
              _buildRecentRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFD32F2F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate('app_name'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            translate('save_lives_donate'),
            style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text(
            '${translate('welcome')}, ${user?.fullName ?? translate('user')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Top Big Card
          SizedBox(
            width: double.infinity, // Make it full width
            child: _buildFeatureCard(
              title: translate('post_blood_request'),
              subtitle: translate('create_urgent_request'),
              icon: Icons.add,
              iconColor: Colors.white,
              textColor: Colors.white,
              backgroundColor: const Color(0xFFD32F2F),
              height: 130, // Adjusted height to be closer to "nearby blood banks" (default aspect ratio)
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequesterPostBloodRequestScreen(),
                  ),
                );
                _refreshRequests();
              },
            ),
          ),
          const SizedBox(height: 16),
          // Bottom Row with Two Cards
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  title: translate('nearby_blood_banks'),
                  subtitle: translate('locate_blood_banks'),
                  icon: Icons.home_work_outlined,
                  iconColor: const Color(0xFFD32F2F),
                  textColor: Colors.black87,
                  backgroundColor: const Color(0xFFFFF5F5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequesterBloodBankScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureCard(
                  title: translate('find_donor'),
                  subtitle: translate('search_nearby_donors'),
                  icon: Icons.people_outline,
                  iconColor: const Color(0xFFD32F2F),
                  textColor: Colors.black87,
                  backgroundColor: const Color(0xFFFFF5F5),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequesterFindDonorScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color backgroundColor,
    double? height,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height, // Optional specific height
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequests() {
    final user = Provider.of<AuthProvider>(context).user;
    if (user == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate('recent_requests'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequesterMyRequestsScreen(),
                    ),
                  );
                  _refreshRequests();
                },
                child: Text(
                  translate('view_all'),
                  style: const TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: ApiService().getRequesterBloodRequests(user.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return Text(translate('no_requests_found'));
              }

              final requests = (snapshot.data as List)
                  .map((json) => BloodRequest.fromJson(json))
                  .toList();

              // Show only top 3 recent requests
              final recentRequests = requests.take(3).toList();

              return Column(
                children: recentRequests
                    .map((request) => _buildRequestCard(request))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'fulfilled':
        return Colors.purple;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
  
  String _getTranslatedStatus(String status) {
     try {
       return translate(status.toLowerCase());
     } catch (e) {
       return status.toUpperCase();
     }
  }

  Widget _buildRequestCard(BloodRequest request) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RequesterRequestDetailsScreen(request: request),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${request.units} ${request.units > 1 ? translate('units_required') : translate('unit_required')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.bloodGroup,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.local_hospital,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      request.hospitalName,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(request.status)),
                    ),
                    child: Text(
                      _getTranslatedStatus(request.status),
                      style: TextStyle(
                        color: _getStatusColor(request.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        request.createdAt.toLocal().toString().split(' ')[0],
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
