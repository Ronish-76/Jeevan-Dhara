import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/auth/login_screen.dart';

class BloodBankProfilePage extends StatefulWidget {
  const BloodBankProfilePage({super.key});

  @override
  State<BloodBankProfilePage> createState() => _BloodBankProfilePageState();
}

class _BloodBankProfilePageState extends State<BloodBankProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      setState(() {
        _profileFuture = _fetchProfile(user.id!);
      });
    } else {
      setState(() {
        _profileFuture = Future.error('User not logged in');
      });
    }
  }

  Future<void> _refreshProfile() async {
    _loadProfile();
    try {
      await _profileFuture;
    } catch (_) {}
  }
  
  Future<Map<String, dynamic>> _fetchProfile(String id) async {
     try {
       return await ApiService().getBloodBankProfile(id);
     } catch (e) {
       throw Exception('Failed to load profile');
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Blood Bank Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Center(child: Text('Error loading profile: ${snapshot.error}')),
                  ),
                ],
              );
            }
            
            final profile = snapshot.data;
            if (profile == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 500,
                    child: Center(child: Text('No profile data found')),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildOrganizationCard(profile),
                  const SizedBox(height: 20),
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
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(Map<String, dynamic> profile) {
    final name = profile['bloodBankName'] ?? 'Blood Bank';
    final subTitle = profile['licenseNumber'] != null ? 'Reg ID: ${profile['licenseNumber']}' : 'Registered Blood Bank';

    return _buildInfoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFFD32F2F), child: Icon(Icons.bloodtype, color: Colors.white, size: 30)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(subTitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFFF9800), borderRadius: BorderRadius.circular(20)),
                child: const Text('Verified', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(Map<String, dynamic> profile) {
    final address = profile['fullAddress'] ?? 'Unknown Address';
    final phone = profile['phoneNumber'] ?? 'Unknown Phone';
    final email = profile['email'] ?? 'Unknown Email';
    
    return _buildInfoCard(
      title: 'Contact Information',
      child: Column(
        children: [
          _buildContactRow(Icons.location_on_outlined, 'Address', address),
          _buildContactRow(Icons.phone_outlined, 'Primary Phone', phone),
          _buildContactRow(Icons.email_outlined, 'Email Address', email),
          _buildContactRow(Icons.language_outlined, 'Website', 'www.jeevandhara.org'), 
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
          const Divider(height:20),
          const Row(children:[Icon(Icons.emergency_outlined, color: Color(0xFFD32F2F), size:18), SizedBox(width:8), Text('24/7 for Emergencies', style:TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize:14))])
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
          _buildChecklistItem('24/7 Emergency Service', hasEmergency),
          _buildChecklistItem('Component Separation', hasComponent),
          _buildChecklistItem('Apheresis Service', hasApheresis),
          _buildChecklistItem('Govt. Registered', true),
        ],
      ),
    );
  }

  Widget _buildActionsPanel(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F))),
          leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)),
          onTap: () async {
            await Provider.of<AuthProvider>(context, listen: false).logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({String? title, required Widget child, EdgeInsets padding = const EdgeInsets.all(16)}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: padding,
        child: title == null
            ? child
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Divider(height: 20), child]),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [Icon(icon, size: 20, color: Colors.grey), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))]))]),
    );
  }

    Widget _buildHoursRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(day, style:const TextStyle(fontSize:14)), Text(hours, style:const TextStyle(fontSize:14, fontWeight:FontWeight.w500))]),
    );
  }

  Widget _buildChecklistItem(String text, bool isChecked) {
    return Row(children: [Icon(isChecked ? Icons.check_circle : Icons.cancel, color: isChecked ? Colors.green : Colors.grey, size: 20), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(fontSize: 14)))]);
  }
}
