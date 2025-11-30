import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

class HospitalDonationsPage extends StatefulWidget {
  const HospitalDonationsPage({super.key});

  @override
  State<HospitalDonationsPage> createState() => _HospitalDonationsPageState();
}

class _HospitalDonationsPageState extends State<HospitalDonationsPage> {
  List<dynamic> _donations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = await ApiService().getHospitalDonations(user.id!);
      if (mounted) {
        setState(() {
          _donations = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Donations Received'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _donations.isEmpty
              ? const Center(child: Text('No donations recorded yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _donations.length,
                  itemBuilder: (context, index) {
                    final donation = _donations[index];
                    return _buildDonationCard(donation);
                  },
                ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final date = DateTime.tryParse(donation['donationDate'] ?? '') ?? DateTime.now();
    final status = donation['status'] ?? 'stocked';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              donation['bloodGroup'] ?? '?',
              style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        title: Text(donation['donorName'] ?? 'Unknown Donor', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${donation['units']} Units • ${dateFormat.format(date)}'),
            if (donation['contactNumber'] != null) Text('Phone: ${donation['contactNumber']}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(status.toString().toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
