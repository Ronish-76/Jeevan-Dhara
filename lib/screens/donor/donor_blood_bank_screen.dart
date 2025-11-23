import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';

// Data model for Blood Bank (Copied for Donor View)
class BloodBank {
  final String id;
  final String name;
  final String location;
  final double distance;
  final String phone;
  
  BloodBank({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.phone,
  });

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    return BloodBank(
      id: json['_id'] ?? '',
      name: json['bloodBankName'] ?? json['hospitalName'] ?? 'Unknown Blood Bank',
      location: json['fullAddress'] ?? json['hospitalLocation'] ?? 'Unknown Location',
      distance: 0.0, 
      phone: json['phoneNumber'] ?? json['hospitalPhone'] ?? '',
    );
  }
}

class DonorBloodBankScreen extends StatefulWidget {
  const DonorBloodBankScreen({super.key});

  @override
  State<DonorBloodBankScreen> createState() => _DonorBloodBankScreenState();
}

class _DonorBloodBankScreenState extends State<DonorBloodBankScreen> {
  late Future<List<BloodBank>> _bloodBanksFuture;

  @override
  void initState() {
    super.initState();
    _bloodBanksFuture = _fetchBloodBanks();
  }

  Future<List<BloodBank>> _fetchBloodBanks() async {
    try {
      final data = await ApiService().getBloodBanks();
      final banks = data.map((json) => BloodBank.fromJson(json)).toList();
      return banks;
    } catch (e) {
      debugPrint('Error fetching blood banks: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: FutureBuilder<List<BloodBank>>(
          future: _bloodBanksFuture,
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.length : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Blood Banks', style: TextStyle(color: Colors.white)),
                Text(
                  '$count blood banks nearby',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildInfoBanner(),
          Expanded(
            child: FutureBuilder<List<BloodBank>>(
              future: _bloodBanksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No blood banks found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return DonorBloodBankCard(bank: snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    final user = Provider.of<AuthProvider>(context).user;
    final isEligible = user?.isEligible ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEligible ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(isEligible ? Icons.check_circle_outline : Icons.info_outline, 
               color: isEligible ? Colors.green : Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEligible 
                  ? 'You are eligible to donate. Select a blood bank to schedule.' 
                  : 'You are currently ineligible to donate due to the waiting period.',
              style: TextStyle(
                color: isEligible ? Colors.green.shade800 : Colors.orange.shade800, 
                fontSize: 12
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonorBloodBankCard extends StatelessWidget {
  final BloodBank bank;
  const DonorBloodBankCard({super.key, required this.bank});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  void _scheduleDonation(BuildContext context) {
    // Placeholder for scheduling logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation scheduled at ${bank.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isEligible = user?.isEligible ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(),
            const SizedBox(height: 16),
            // Removed Stock Grid
            _buildActionButtons(context, isEligible),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.home_work_outlined, color: Color(0xFFD32F2F), size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bank.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              Text(bank.location, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
              const SizedBox(height: 4),
              if (bank.phone.isNotEmpty)
                Text(bank.phone, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isEligible) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isEligible ? () => _scheduleDonation(context) : null,
            icon: const Icon(Icons.calendar_today, size: 20),
            label: const Text('SCHEDULE DONATION'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFD32F2F),
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: isEligible ? 2 : 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: (bank.phone.isNotEmpty) ? () => _makePhoneCall(bank.phone) : null,
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {}, // Placeholder for direction
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                  side: const BorderSide(color: Color(0xFFD32F2F)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
