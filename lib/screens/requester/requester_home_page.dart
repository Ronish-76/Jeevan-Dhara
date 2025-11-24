import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/map/blood_bank_request_map_screen.dart';
import 'package:jeevandhara/screens/requester/requester_emergency_delivery_screen.dart';
import 'package:jeevandhara/screens/requester/requester_find_donor_screen.dart';
import 'package:jeevandhara/screens/requester/requester_post_blood_request_screen.dart';
import 'package:jeevandhara/screens/requester/requester_my_requests_screen.dart';
import 'package:jeevandhara/screens/requester/requester_request_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/models/blood_request_model.dart';

class RequesterHomePage extends StatefulWidget {
  final User user;

  const RequesterHomePage({super.key, required this.user});

  @override
  State<RequesterHomePage> createState() => _RequesterHomePageState();
}

class _RequesterHomePageState extends State<RequesterHomePage> {
  
  void _refreshRequests() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildFeatureGrid(),
            const SizedBox(height: 20),
            _buildMyRequests(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
<<<<<<< HEAD
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
          const Text(
            'Jeevan Dhara',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Save lives, donate blood',
            style: TextStyle(color: Color(0xFFF5F5F5), fontSize: 16),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome, ${user?.fullName ?? 'User'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
=======
    // ... This widget is fine, no changes needed ...
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFD32F2F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Jeevan Dhara',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Save lives, donate blood',
                      style: TextStyle(color: Color(0xFFF5F5F5), fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Color(0xFFD32F2F),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search donors, requests, or blood banks',
                  border: InputBorder.none,
                ),
              ),
>>>>>>> map-feature
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
        children: [
          _buildFeatureCard(
            title: 'Post Blood Request',
            subtitle: 'Create urgent request',
            icon: Icons.add,
            iconColor: Colors.white,
            textColor: Colors.white,
            backgroundColor: const Color(0xFFD32F2F),
<<<<<<< HEAD
            onTap: () async {
              await Navigator.push(
=======
            onTap: () {
              Navigator.push(
>>>>>>> map-feature
                context,
                MaterialPageRoute(
                  builder: (context) => const RequesterPostBloodRequestScreen(),
                ),
              );
<<<<<<< HEAD
              _refreshRequests();
=======
>>>>>>> map-feature
            },
          ),
          _buildFeatureCard(
            title: 'Find Donor',
            subtitle: 'Search nearby donors',
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
          _buildFeatureCard(
            title: 'Nearby Blood Banks',
            subtitle: 'Locate blood banks',
            icon: Icons.home_work_outlined,
            iconColor: const Color(0xFFD32F2F),
            textColor: Colors.black87,
            backgroundColor: const Color(0xFFFFF5F5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
<<<<<<< HEAD
                  builder: (context) => const RequesterBloodBankScreen(),
=======
                  builder: (context) => const BloodBankRequestMapScreen(),
>>>>>>> map-feature
                ),
              );
            },
          ),
          _buildFeatureCard(
            title: 'Emergency Delivery',
            subtitle: 'Request fast delivery',
            icon: Icons.local_shipping_outlined,
            iconColor: Colors.white,
            textColor: Colors.white,
            backgroundColor: const Color(0xFFC62828),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
<<<<<<< HEAD
                      const RequesterEmergencyDeliveryScreen(),
=======
                  const RequesterEmergencyDeliveryScreen(),
>>>>>>> map-feature
                ),
              );
            },
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
=======
  // ... The rest of the file is unchanged and correct ...
>>>>>>> map-feature
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
<<<<<<< HEAD
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
=======
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
>>>>>>> map-feature
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

  Widget _buildMyRequests() {
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
              const Text(
<<<<<<< HEAD
                'My Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
=======
                'Recent Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
>>>>>>> map-feature
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
<<<<<<< HEAD
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
                return const Text('No requests found.');
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
=======
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD32F2F).withOpacity(0.1),
                  ),
                  child: const Icon(Icons.water_drop, color: Color(0xFFD32F2F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Ramesh Kumar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '2 units',
                            style: TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildPillTag(
                            'O+',
                            const Color(0xFFD32F2F),
                            Colors.white,
                          ),
                          const SizedBox(width: 6),
                          _buildPillTag(
                            'Critical',
                            const Color(0xFFC62828),
                            Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Kathmandu Medical College',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.grey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '15 min ago',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
>>>>>>> map-feature
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
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
                        '${request.units} Unit${request.units > 1 ? 's' : ''} Required',
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
                      request.status.toUpperCase(),
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
              // Removed Action Buttons (Delete/Cancel) as per request for Home Page view
            ],
          ),
=======
  Widget _buildPillTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
>>>>>>> map-feature
        ),
      ),
    );
  }
}
