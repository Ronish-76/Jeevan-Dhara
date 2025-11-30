import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/screens/requester/blood_bank_map_screen.dart'; 
import 'package:jeevandhara/screens/requester/requester_blood_bank_screen.dart' as requester;
import 'package:flutter_translate/flutter_translate.dart';

class Hospital {
  final String id;
  final String name;
  final String location;
  final double distance;
  final String phone;
  final double latitude;
  final double longitude;
  
  Hospital({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.phone,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['_id'] ?? '',
      name: json['hospitalName'] ?? json['fullName'] ?? 'Unknown Hospital',
      location: json['hospitalLocation'] ?? json['address'] ?? json['location'] ?? 'Unknown Location',
      distance: 0.0, 
      phone: json['hospitalPhone'] ?? json['phoneNumber'] ?? json['phone'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DonorHospitalsScreen extends StatefulWidget {
  const DonorHospitalsScreen({super.key});

  @override
  State<DonorHospitalsScreen> createState() => _DonorHospitalsScreenState();
}

class _DonorHospitalsScreenState extends State<DonorHospitalsScreen> {
  late Future<List<Hospital>> _hospitalsFuture;
  List<Hospital> _allHospitals = [];

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _fetchHospitals();
  }

  Future<List<Hospital>> _fetchHospitals() async {
    try {
      final data = await ApiService().searchHospitals('');
      final hospitals = data.map((json) => Hospital.fromJson(json)).toList();
      _allHospitals = hospitals;
      return hospitals;
    } catch (e) {
      debugPrint('Error fetching hospitals: $e');
      return [];
    }
  }

  // Helper to convert Hospital to requester.BloodBank (map requires BloodBank type)
  requester.BloodBank createRequesterBloodBankFromHospital(Hospital h) {
    return requester.BloodBank(
      id: h.id,
      name: h.name,
      location: h.location,
      distance: h.distance,
      phone: h.phone,
      stock: {}, 
      latitude: h.latitude,
      longitude: h.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: FutureBuilder<List<Hospital>>(
          future: _hospitalsFuture,
          builder: (context, snapshot) {
            final count = snapshot.hasData ? snapshot.data!.length : 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(translate('nearby_hospitals'), style: const TextStyle(color: Colors.white)),
                Text(
                  translate('hospitals_nearby_count', args: {'count': count}),
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
            child: FutureBuilder<List<Hospital>>(
              future: _hospitalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(translate('no_hospitals_found')));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return DonorHospitalCard(hospital: snapshot.data![index]);
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
          if (_allHospitals.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BloodBankMapScreen(
                  bloodBanks: _allHospitals.map((h) => 
                    createRequesterBloodBankFromHospital(h)
                  ).toList(),
                ),
              ),
            );
          } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(translate('no_hospitals_map'))),
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

class DonorHospitalCard extends StatelessWidget {
  final Hospital hospital;
  const DonorHospitalCard({super.key, required this.hospital});

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

  // Helper to convert Hospital to requester.BloodBank
  requester.BloodBank createRequesterBloodBankFromHospital(Hospital h) {
    return requester.BloodBank(
      id: h.id,
      name: h.name,
      location: h.location,
      distance: h.distance,
      phone: h.phone,
      stock: {}, 
      latitude: h.latitude,
      longitude: h.longitude,
    );
  }

  Future<void> _openMap(BuildContext context) async {
    // If we have lat/long, use the app's map screen first
    if (hospital.latitude != 0.0 && hospital.longitude != 0.0) {
       final reqBank = createRequesterBloodBankFromHospital(hospital);
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BloodBankMapScreen(bloodBanks: [reqBank]),
          ),
        );
    } else {
      // Fallback to Google Maps web/app
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(hospital.location)}');
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
     String query = Uri.encodeComponent(hospital.location);
     if (hospital.latitude != 0.0 && hospital.longitude != 0.0) {
       query = '${hospital.latitude},${hospital.longitude}';
     }
     final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$query');
          
     if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        throw 'Could not launch maps';
      }
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_hospital, color: Color(0xFFD32F2F), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                       GestureDetector(
                        onTap: () => _openMap(context),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Color(0xFFD32F2F)),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                hospital.location, 
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
                      if (hospital.phone.isNotEmpty)
                        Text(hospital.phone, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (hospital.phone.isNotEmpty) ? () => _makePhoneCall(hospital.phone) : null,
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
        ),
      ),
    );
  }
}
