import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  bool _isLoading = true;
  List<dynamic> _donations = [];

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) return;

      final data = await ApiService().getDonations(user.id!);
      if (mounted) {
        setState(() {
          _donations = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching donations: $e');
      if (mounted) setState(() => _isLoading = false);
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donation History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('All donor contributions', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildQuickStats(),
                const SizedBox(height: 16),
                _buildFilterControls(),
                const SizedBox(height: 16),
                _buildDonationsList(),
              ],
            ),
    );
  }

  Widget _buildQuickStats() {
    int totalDonations = _donations.length;
    int totalUnits = 0;
    for (var d in _donations) {
      totalUnits += (d['units'] as num).toInt();
    }
    // Assuming all recorded donations are Verified for now as they are entered by bank staff
    int verified = totalDonations; 
    int pending = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: totalDonations.toString(), label: 'Total Donations'),
        _StatItem(value: totalUnits.toString(), label: 'Total Units'),
        _StatItem(value: verified.toString(), label: 'Verified'),
        _StatItem(value: pending.toString(), label: 'Pending'),
      ],
    );
  }

  Widget _buildFilterControls() {
    return const Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Status', style: TextStyle(fontWeight: FontWeight.w500)),
            Icon(Icons.arrow_drop_down),
            VerticalDivider(),
            Text('All Time', style: TextStyle(fontWeight: FontWeight.w500)),
            Icon(Icons.arrow_drop_down),
            VerticalDivider(),
            Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsList() {
    if (_donations.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('No donation history found.'),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Donations (${_donations.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ..._donations.map((d) => _buildDonationCard(d)).toList(),
      ],
    );
  }

  Widget _buildDonationCard(dynamic donation) {
    final name = donation['donorName'] ?? 'Unknown Donor';
    final id = (donation['_id'] as String).substring(0, 8).toUpperCase(); // Short ID
    final units = donation['units'];
    final blood = donation['bloodGroup'];
    // Assuming verified since it's in history
    const status = 'Verified'; 
    const color = Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('ID: $id', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('$units Unit(s), Blood Group: $blood', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  if (donation['donationDate'] != null)
                    Text(
                      DateFormat('MMM dd, yyyy').format(DateTime.parse(donation['donationDate'])),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
