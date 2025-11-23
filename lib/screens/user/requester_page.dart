import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/blood_request_viewmodel.dart';
import '../requester/requester_blood_bank_screen.dart';
import 'emergency_delivery_screen.dart';
import 'find_donor_screen.dart';
import 'post_blood_request_screen.dart';

class RequesterPage extends StatefulWidget {
  const RequesterPage({super.key});

  @override
  State<RequesterPage> createState() => _RequesterPageState();
}

class _RequesterPageState extends State<RequesterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodRequestViewModel>().fetchActiveRequests(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: RefreshIndicator(
        onRefresh: () => context.read<BloodRequestViewModel>().fetchActiveRequests(
          forceRefresh: true,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFeatureGrid(),
              const SizedBox(height: 20),
              _buildRecentRequests(bloodRequestViewModel),
            ],
          ),
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
                    color: Colors.black.withValues(alpha: 0.1),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostBloodRequestScreen(),
                ),
              );
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
                  builder: (context) => const FindDonorScreen(),
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
                  builder: (context) => const RequesterBloodBankScreen(),
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
                  builder: (context) => const EmergencyDeliveryScreen(),
                ),
              );
            },
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
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
              style: TextStyle(color: textColor.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRequests(BloodRequestViewModel provider) {
    final requests = provider.requests;
    final isLoading = provider.isLoading;
    final BloodRequestModel? latest = requests.isNotEmpty
        ? requests.first
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Requests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () =>
                    provider.fetchActiveRequests(forceRefresh: true),
                child: const Text(
                  'Refresh',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoading && requests.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (latest == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No active requests yet. Create one to see updates in real-time.',
              ),
            )
          else ...[
            _buildPrimaryRequestCard(latest),
            const SizedBox(height: 12),
            ...requests.skip(1).take(3).map(_buildSecondaryRequestTile),
          ],
        ],
      ),
    );
  }

  Widget _buildPrimaryRequestCard(BloodRequestModel request) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.requesterName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              _buildPillTag(
                '${request.units} units',
                const Color(0xFFD32F2F),
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildPillTag(
                request.bloodType,
                const Color(0xFFD32F2F),
                Colors.white,
              ),
              const SizedBox(width: 6),
              _buildPillTag(
                request.status.toUpperCase(),
                request.status == 'responded'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFC62828),
                Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  request.locationName ?? 'Shared via map',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                '${(request.createdAt ?? DateTime.now()).hour.toString().padLeft(2, '0')}:${(request.createdAt ?? DateTime.now()).minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EmergencyDeliveryScreen(request: request),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
              ),
              child: const Text('Track & Manage'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryRequestTile(BloodRequestModel request) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFEBEE),
          child: Text(
            request.bloodType,
            style: const TextStyle(
              color: Color(0xFFD32F2F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          request.requesterName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${request.units} units • ${request.status}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmergencyDeliveryScreen(request: request),
            ),
          ),
        ),
      ),
    );
  }

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
        ),
      ),
    );
  }
}
