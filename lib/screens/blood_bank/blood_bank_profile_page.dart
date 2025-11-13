import 'package:flutter/material.dart';

class BloodBankProfilePage extends StatelessWidget {
  const BloodBankProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Blood Bank Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOrganizationCard(),
            const SizedBox(height: 20),
            _buildPerformanceDashboard(),
            const SizedBox(height: 20),
            _buildContactInfoCard(),
            const SizedBox(height: 20),
            _buildOperatingHoursCard(),
            const SizedBox(height: 20),
            _buildCertificationsCard(),
            const SizedBox(height: 20),
            _buildActionsPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationCard() {
    return _buildInfoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFFD32F2F), child: Icon(Icons.bloodtype, color: Colors.white, size: 30)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Central Blood Bank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Government Recognized Blood Bank', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
          const Divider(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricItem(value: '10K+', label: 'Donations'),
              _MetricItem(value: '8K+', label: 'Requests'),
              _MetricItem(value: '12Y', label: 'Service'),
              _MetricItem(value: '98%', label: 'Success Rate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDashboard() {
    return _buildInfoCard(
      title: 'Performance & Analytics',
      child: const Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ Text('Today\'s Activity'), Text('Monthly Goal'),]),
           SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _MetricItem(value: '22', label: 'Donations'), _MetricItem(value: '75%', label: 'of 400 units'),]),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return _buildInfoCard(
      title: 'Contact Information',
      child: Column(
        children: [
          _buildContactRow(Icons.location_on_outlined, 'Address', 'Mahabouddha, Kathmandu, Nepal'),
          _buildContactRow(Icons.phone_outlined, 'Primary Phone', '+977 1-4221119'),
          _buildContactRow(Icons.email_outlined, 'Email Address', 'info@centralbloodbank.org.np'),
          _buildContactRow(Icons.language_outlined, 'Website', 'www.centralbloodbank.org.np'),
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

  Widget _buildCertificationsCard() {
    return _buildInfoCard(
      title: 'Certifications & Compliance',
      child: Column(
        children: [
          _buildChecklistItem('ISO 9001:2015 Certified', true),
          _buildChecklistItem('National Public Health Laboratory Certified', true),
          _buildChecklistItem('Regularly Audited by Dept. of Drug Administration', true),
        ],
      ),
    );
  }

  Widget _buildActionsPanel(BuildContext context) {
    return Column(
      children: [
        ListTile(title: const Text('Settings'), leading: const Icon(Icons.settings_outlined), onTap: () {}),
        ListTile(title: const Text('Logout', style: TextStyle(color: Color(0xFFD32F2F))), leading: const Icon(Icons.logout, color: Color(0xFFD32F2F)), onTap: () {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const UserSelectionScreen()), (route) => false); // Placeholder
        }),
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

class _MetricItem extends StatelessWidget {
  final String value, label;
  const _MetricItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
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
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('User Selection Screen')));
}
