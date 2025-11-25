import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/requester/requester_blood_bank_screen.dart';
import 'package:jeevandhara/screens/user/emergency_delivery_screen.dart';
import 'package:jeevandhara/screens/user/find_donor_screen.dart';
import 'package:jeevandhara/screens/user/post_blood_request_screen.dart';

class RequesterPage extends StatefulWidget {
  const RequesterPage({super.key});

  @override
  State<RequesterPage> createState() => _RequesterPageState();
}

class _RequesterPageState extends State<RequesterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildFeatureGrid(),
            const SizedBox(height: 20),
            _buildRecentRequests(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 200, // Reduced height
      child: Stack(
        children: [
          Container(
            height: 180, // Reduced height
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
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                  child: const Icon(Icons.water_drop, color: Color(0xFFD32F2F), size: 28),
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search donors, requests, or blood banks',
                  border: InputBorder.none,
                ),
              ),
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
        children: [
          _buildFeatureCard(
              title: 'Post Blood Request',
              subtitle: 'Create urgent request',
              icon: Icons.add,
              iconColor: Colors.white,
              textColor: Colors.white,
              backgroundColor: const Color(0xFFD32F2F),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PostBloodRequestScreen()));
              }),
          _buildFeatureCard(
              title: 'Find Donor',
              subtitle: 'Search nearby donors',
              icon: Icons.people_outline,
              iconColor: const Color(0xFFD32F2F),
              textColor: Colors.black87,
              backgroundColor: const Color(0xFFFFF5F5),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FindDonorScreen()));
              }),
          _buildFeatureCard(
              title: 'Nearby Blood Banks',
              subtitle: 'Locate blood banks',
              icon: Icons.home_work_outlined,
              iconColor: const Color(0xFFD32F2F),
              textColor: Colors.black87,
              backgroundColor: const Color(0xFFFFF5F5),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RequesterBloodBankScreen()));
              }),
          _buildFeatureCard(
              title: 'Emergency Delivery',
              subtitle: 'Request fast delivery',
              icon: Icons.local_shipping_outlined,
              iconColor: Colors.white,
              textColor: Colors.white,
              backgroundColor: const Color(0xFFC62828),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyDeliveryScreen()));
              }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({required String title, required String subtitle, required IconData icon, required Color iconColor, required Color textColor, required Color backgroundColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
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
              const Text('Recent Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: Color(0xFFD32F2F)))),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD32F2F).withOpacity(0.1)),
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
                          Text('Ramesh Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('2 units', style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildPillTag('O+', const Color(0xFFD32F2F), Colors.white),
                          const SizedBox(width: 6),
                          _buildPillTag('Critical', const Color(0xFFC62828), Colors.white),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.location_on, color: Colors.grey, size: 16), const SizedBox(width: 4), const Text('Kathmandu Medical College', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                      const SizedBox(height: 4),
                      Row(children: [const Icon(Icons.access_time, color: Colors.grey, size: 16), const SizedBox(width: 4), const Text('15 min ago', style: TextStyle(color: Colors.grey, fontSize: 12))]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
