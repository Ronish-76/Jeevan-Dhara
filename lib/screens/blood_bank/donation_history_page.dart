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
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

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
      body: RefreshIndicator(
        onRefresh: _fetchDonations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildDonationsList(),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickStats() {
    int totalDonations = _donations.length;
    int totalUnits = 0;
    for (var d in _donations) {
      totalUnits += (d['units'] as num).toInt();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: totalDonations.toString(), label: 'Total Donations'),
        _StatItem(value: totalUnits.toString(), label: 'Total Units'),
      ],
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
