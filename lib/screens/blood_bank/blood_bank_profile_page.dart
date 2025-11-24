import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:jeevandhara/screens/auth/user_selection_screen.dart';

=======

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

>>>>>>> map-feature
class BloodBankProfilePage extends StatefulWidget {
  const BloodBankProfilePage({super.key});

  @override
  State<BloodBankProfilePage> createState() => _BloodBankProfilePageState();
}

class _BloodBankProfilePageState extends State<BloodBankProfilePage> {
<<<<<<< HEAD
  late Future<Map<String, dynamic>> _profileFuture;
=======
  bool _initialized = false;
>>>>>>> map-feature

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      _profileFuture = ApiService().getBloodBankProfile(user.id!).then((data) => data as Map<String, dynamic>);
    } else {
      _profileFuture = Future.error('User not logged in');
=======
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final bloodRequestViewModel = context.read<BloodRequestViewModel>();
    final inventoryViewModel = context.read<InventoryViewModel>();
    await Future.wait([
      bloodRequestViewModel.fetchActiveRequests(forceRefresh: true),
      inventoryViewModel.fetchNearbyFacilities(role: UserRole.bloodBank),
    ]);
    if (mounted) {
      setState(() => _initialized = true);
>>>>>>> map-feature
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final bloodRequestViewModel = context.watch<BloodRequestViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
<<<<<<< HEAD
        title: const Text('Blood Bank Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [], // Removed Edit Icon
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading profile: ${snapshot.error}'));
          }
          
          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('No profile data found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildOrganizationCard(profile),
                const SizedBox(height: 20),
                // _buildPerformanceDashboard(), // Removing as it seems related to analytics/metrics context
                _buildContactInfoCard(profile),
                const SizedBox(height: 20),
                _buildOperatingHoursCard(), 
                const SizedBox(height: 20),
                _buildCertificationsCard(profile),
                const SizedBox(height: 20),
                _buildActionsPanel(context),
              ],
            ),
          );
        },
=======
        title: const Text(
          'Blood Bank Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildOrganizationCard(facility),
              const SizedBox(height: 20),
              _buildPerformanceDashboard(bloodRequestViewModel, facility),
              const SizedBox(height: 20),
              _buildContactInfoCard(facility),
              const SizedBox(height: 20),
              _buildOperatingHoursCard(),
              const SizedBox(height: 20),
              _buildCertificationsCard(),
              const SizedBox(height: 20),
              _buildActionsPanel(context),
            ],
          ),
        ),
>>>>>>> map-feature
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildOrganizationCard(Map<String, dynamic> profile) {
    final name = profile['bloodBankName'] ?? 'Blood Bank';
    final subTitle = profile['registrationNumber'] != null ? 'Reg ID: ${profile['registrationNumber']}' : 'Registered Blood Bank';

=======
  Widget _buildOrganizationCard(facility) {
>>>>>>> map-feature
    return _buildInfoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFD32F2F),
                child: Icon(Icons.bloodtype, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(subTitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
=======
                    Text(
                      facility?.name ?? 'Blood Bank',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      facility?.displayAddress ?? 'Blood Bank',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
>>>>>>> map-feature
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
<<<<<<< HEAD
          // Removed Metrics Row (Donations, Requests, Service, Success Rate)
=======
          const Divider(height: 30),
          Builder(
            builder: (context) {
              final bloodRequestViewModel = Provider.of<BloodRequestViewModel>(context);
              final requests = bloodRequestViewModel.requests;
              final totalRequests = requests.length;
              final inventoryViewModel = Provider.of<InventoryViewModel>(context);
              final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
                  ? inventoryViewModel.nearbyFacilities.first
                  : null;
              final inventory = facility?.inventory ?? {};
              final totalUnits = inventory.values.fold<int>(
                0,
                (sum, units) => sum + units,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricItem(value: totalUnits.toString(), label: 'Units'),
                  _MetricItem(
                    value: totalRequests.toString(),
                    label: 'Requests',
                  ),
                  _MetricItem(value: '12Y', label: 'Service'),
                  _MetricItem(value: '98%', label: 'Success Rate'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDashboard(BloodRequestViewModel bloodRequestViewModel, facility) {
    final todayRequests = bloodRequestViewModel.requests
        .where(
          (r) =>
              r.createdAt != null &&
              r.createdAt!.day == DateTime.now().day &&
              r.createdAt!.month == DateTime.now().month &&
              r.createdAt!.year == DateTime.now().year,
        )
        .length;
    final inventory = facility?.inventory ?? {};
    final totalUnits = inventory.values.fold<int>(
      0,
      (sum, units) => sum + units,
    );
    final goalProgress = totalUnits > 0
        ? (totalUnits / 400 * 100).toStringAsFixed(0)
        : '0';

    return _buildInfoCard(
      title: 'Performance & Analytics',
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text('Today\'s Activity'), Text('Monthly Goal')],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(value: todayRequests.toString(), label: 'Requests'),
              _MetricItem(value: '$goalProgress%', label: 'of 400 units'),
            ],
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }

<<<<<<< HEAD
  // Removed _buildPerformanceDashboard as it's likely what user meant or at least related unwanted metrics

  Widget _buildContactInfoCard(Map<String, dynamic> profile) {
    final address = profile['fullAddress'] ?? 'Unknown Address';
    final phone = profile['phoneNumber'] ?? 'Unknown Phone';
    final email = profile['email'] ?? 'Unknown Email';
    
=======
  Widget _buildContactInfoCard(facility) {
>>>>>>> map-feature
    return _buildInfoCard(
      title: 'Contact Information',
      child: Column(
        children: [
<<<<<<< HEAD
          _buildContactRow(Icons.location_on_outlined, 'Address', address),
          _buildContactRow(Icons.phone_outlined, 'Primary Phone', phone),
          _buildContactRow(Icons.email_outlined, 'Email Address', email),
          _buildContactRow(Icons.language_outlined, 'Website', 'www.jeevandhara.org'), // Placeholder
=======
          _buildContactRow(
            Icons.location_on_outlined,
            'Address',
            facility?.displayAddress ?? 'Address not available',
          ),
          _buildContactRow(
            Icons.phone_outlined,
            'Primary Phone',
            facility?.contactNumber ?? 'Not available',
          ),
          if (facility?.email != null)
            _buildContactRow(
              Icons.email_outlined,
              'Email Address',
              facility!.email!,
            ),
>>>>>>> map-feature
        ],
      ),
    );
  }

  Widget _buildOperatingHoursCard() {
    return _buildInfoCard(
      title: 'Operating Hours',
      child: Column(
        children: [
          _buildHoursRow('Sunday - Friday', '9:00 AM - 5:00 PM'),
          _buildHoursRow('Saturday', 'Closed'),
          const Divider(height: 20),
          const Row(
            children: [
              Icon(
                Icons.emergency_outlined,
                color: Color(0xFFD32F2F),
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                '24/7 for Emergencies',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsCard(Map<String, dynamic> profile) {
    final hasEmergency = profile['emergencyService24x7'] == true;
    final hasComponent = profile['componentSeparation'] == true;
    final hasApheresis = profile['apheresisService'] == true;

    return _buildInfoCard(
      title: 'Services & Compliance',
      child: Column(
        children: [
<<<<<<< HEAD
          _buildChecklistItem('24/7 Emergency Service', hasEmergency),
          _buildChecklistItem('Component Separation', hasComponent),
          _buildChecklistItem('Apheresis Service', hasApheresis),
          _buildChecklistItem('Govt. Registered', true),
=======
          _buildChecklistItem('ISO 9001:2015 Certified', true),
          _buildChecklistItem(
            'National Public Health Laboratory Certified',
            true,
          ),
          _buildChecklistItem(
            'Regularly Audited by Dept. of Drug Administration',
            true,
          ),
>>>>>>> map-feature
        ],
      ),
    );
  }

  Widget _buildActionsPanel(BuildContext context) {
    return Column(
      children: [
<<<<<<< HEAD
        // Removed Settings Tile
        ListTile(
          title: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F))),
          leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
          onTap: () async {
            await Provider.of<AuthProvider>(context, listen: false).logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const UserSelectionScreen()),
                (route) => false,
              );
            }
=======
        ListTile(
          title: const Text('Settings'),
          leading: const Icon(Icons.settings_outlined),
          onTap: () {},
        ),
        ListTile(
          title: const Text(
            'Logout',
            style: TextStyle(color: Color(0xFFD32F2F)),
          ),
          leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const UserSelectionScreen(),
              ),
              (route) => false,
            ); // Placeholder
>>>>>>> map-feature
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    String? title,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: padding,
        child: title == null
            ? child
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 20),
                  child,
                ],
              ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 14)),
          Text(
            hours,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle : Icons.cancel,
          color: isChecked ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}
<<<<<<< HEAD
=======

class _MetricItem extends StatelessWidget {
  final String value, label;
  const _MetricItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// Dummy UserSelectionScreen for navigation placeholder
class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('User Selection Screen')));
}
>>>>>>> map-feature
