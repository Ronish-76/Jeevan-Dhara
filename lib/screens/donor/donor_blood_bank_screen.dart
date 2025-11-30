import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/requester/blood_bank_map_screen.dart'; 
import 'package:jeevandhara/screens/requester/requester_blood_bank_screen.dart' as requester;
import 'package:flutter_translate/flutter_translate.dart';

// Data model for Blood Bank (Copied for Donor View)
class BloodBank {
  final String id;
  final String name;
  final String location;
  final double distance;
  final String phone;
  final double latitude;
  final double longitude;
  // Donors don't need to see stock detailed breakdown usually, but model might have it
  
  BloodBank({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.phone,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    return BloodBank(
      id: json['_id'] ?? '',
      name: json['bloodBankName'] ?? json['hospitalName'] ?? 'Unknown Blood Bank',
      location: json['fullAddress'] ?? json['hospitalLocation'] ?? 'Unknown Location',
      distance: 0.0, 
      phone: json['phoneNumber'] ?? json['hospitalPhone'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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
  List<BloodBank> _allBloodBanks = [];

  @override
  void initState() {
    super.initState();
    _bloodBanksFuture = _fetchBloodBanks();
  }

  Future<List<BloodBank>> _fetchBloodBanks() async {
    try {
      final data = await ApiService().getBloodBanks();
      final banks = data.map((json) => BloodBank.fromJson(json)).toList();
      _allBloodBanks = banks;
      return banks;
    } catch (e) {
      debugPrint('Error fetching blood banks: $e');
      return [];
    }
  }

  requester.BloodBank createRequesterBloodBank(BloodBank b) {
    return requester.BloodBank(
      id: b.id,
      name: b.name,
      location: b.location,
      distance: b.distance,
      phone: b.phone,
      stock: {}, 
      latitude: b.latitude,
      longitude: b.longitude,
    );
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
                Text(translate('nearby_blood_banks'), style: const TextStyle(color: Colors.white)),
                Text(
                  translate('blood_banks_nearby_count', args: {'count': count}),
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
          _buildMapSection(),
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
                  return Center(child: Text(translate('no_blood_banks_found')));
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

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (_allBloodBanks.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BloodBankMapScreen(
                  bloodBanks: _allBloodBanks.map((b) => 
                    createRequesterBloodBank(b)
                  ).toList(),
                ),
              ),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(translate('no_blood_banks_map'))),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                translate('see_in_maps'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
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

  requester.BloodBank createRequesterBloodBank(BloodBank b) {
    return requester.BloodBank(
      id: b.id,
      name: b.name,
      location: b.location,
      distance: b.distance,
      phone: b.phone,
      stock: {}, 
      latitude: b.latitude,
      longitude: b.longitude,
    );
  }

  Future<void> _openMap(BuildContext context) async {
    final reqBank = createRequesterBloodBank(bank);
    
    if (bank.latitude != 0.0 && bank.longitude != 0.0) {
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BloodBankMapScreen(bloodBanks: [reqBank]),
          ),
        );
    } else {
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(bank.location)}');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(translate('could_not_open_maps'))),
          );
        }
      }
    }
  }
  
  Future<void> _openDirections() async {
     String query = Uri.encodeComponent(bank.location);
     if (bank.latitude != 0.0 && bank.longitude != 0.0) {
       query = '${bank.latitude},${bank.longitude}';
     }
     final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$query');
          
     if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        throw 'Could not launch maps';
      }
  }

  void _scheduleDonation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translate('donation_scheduled', args: {'name': bank.name}))),
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
            _buildCardHeader(context),
            const SizedBox(height: 16),
            _buildActionButtons(context, isEligible),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
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
               GestureDetector(
                onTap: () => _openMap(context),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFFD32F2F)),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        bank.location, 
                        style: const TextStyle(
                          color: Color(0xFF666666), 
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            label: Text(translate('schedule_donation').toUpperCase()),
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
                label: Text(translate('call')),
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
                onPressed: _openDirections,
                icon: const Icon(Icons.directions, size: 18),
                label: Text(translate('directions')),
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
