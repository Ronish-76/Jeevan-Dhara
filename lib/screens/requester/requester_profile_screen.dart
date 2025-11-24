import 'package:flutter/material.dart';
import 'package:jeevandhara/models/blood_request_model.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';

class RequesterProfileScreen extends StatefulWidget {
  const RequesterProfileScreen({super.key});

  @override
  State<RequesterProfileScreen> createState() => _RequesterProfileScreenState();
}

class _RequesterProfileScreenState extends State<RequesterProfileScreen> {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [],
          ),
          body: SingleChildScrollView(
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildProfileHeader(user),
                      _buildRequestStatistics(user.id!),
                      _buildInfoCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        details: {
                          'Full Name': user.fullName ?? '',
                          'Email': user.email ?? '',
                          'Phone': user.phone ?? '',
                        },
                      ),
                      _buildHospitalContactsCard(user),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () => _logout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    final hospitalNameController = TextEditingController(text: user?.hospital);
    final locationController = TextEditingController(
      text: user?.hospitalLocation,
    );
    final phoneController = TextEditingController(text: user?.hospitalPhone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Hospital Details'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: hospitalNameController,
                  decoration: const InputDecoration(labelText: 'Hospital Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Location',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital Phone',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
=======
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
>>>>>>> map-feature
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              bool isLoading = false;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          try {
                            final success = await authProvider.updateProfile({
                              'hospitalName': hospitalNameController.text,
                              'hospitalLocation': locationController.text,
                              'hospitalPhone': phoneController.text,
                            });

                            if (!context.mounted) return;

                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile updated successfully!',
                                  ),
                                ),
                              );
                            } else {
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Update failed: ${authProvider.errorMessage}',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
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
<<<<<<< HEAD
          Text(
            user?.fullName ?? '',
            style: const TextStyle(
=======
          const Text(
            'Ramesh Kumar',
            style: TextStyle(
>>>>>>> map-feature
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

<<<<<<< HEAD
  Widget _buildRequestStatistics(String userId) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService().getRequesterBloodRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching stats'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '0',
                    'Requests Made',
                    Icons.add_alert_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    '0',
                    'Requests Fulfilled',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
              ],
            ),
          );
        }

        final requests = (snapshot.data as List)
            .map((json) => BloodRequest.fromJson(json))
            .toList();

        final requestsMade = requests.length;
        final requestsFulfilled = requests
            .where((req) => req.status == 'fulfilled')
            .length;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  requestsMade.toString(),
                  'Requests Made',
                  Icons.add_alert_outlined,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  requestsFulfilled.toString(),
                  'Requests Fulfilled',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
            ],
          ),
        );
      },
=======
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
>>>>>>> map-feature
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

<<<<<<< HEAD
  Widget _buildHospitalContactsCard(dynamic user) {
=======
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Map<String, String> details,
  }) {
>>>>>>> map-feature
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
<<<<<<< HEAD
                const Icon(
                  Icons.local_hospital_outlined,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hospital Contacts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                  onPressed: _showEditProfileDialog,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildContactRow(
              Icons.business,
              'Hospital',
              user?.hospital ?? 'Not set',
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Icons.location_on_outlined,
              'Location',
              user?.hospitalLocation ?? 'Add location',
            ),
            const SizedBox(height: 16),
            _buildContactRow(
              Icons.phone_outlined,
              'Phone',
              user?.hospitalPhone ?? 'Add phone',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return InkWell(
      onTap: _showEditProfileDialog,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFFD32F2F)),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
=======
                Icon(icon, color: const Color(0xFFD32F2F)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
>>>>>>> map-feature
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
=======
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
>>>>>>> map-feature
          ],
        ),
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
<<<<<<< HEAD
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
=======
            const Row(
              children: [
                Icon(Icons.history, color: Color(0xFFD32F2F)),
                SizedBox(width: 8),
                Text(
                  'Recent Requests',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
>>>>>>> map-feature
                ),
              ],
            ),
            const Divider(height: 24),
<<<<<<< HEAD
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
=======
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
>>>>>>> map-feature
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

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
>>>>>>> map-feature
}
