import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jeevandhara/screens/requester/blood_bank_map_screen.dart';

// Data model for Blood Bank
class BloodBank {
  final String id;
  final String name;
  final String location;
  final double distance;
  final String phone;
  final Map<String, int> stock;
  final double latitude;
  final double longitude;

  BloodBank({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.phone,
    required this.stock,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  factory BloodBank.fromJson(Map<String, dynamic> json) {
    // Helper function to convert dynamic map to Map<String, int>
    Map<String, int> parseStock(dynamic stockData) {
      if (stockData == null) return {};
      final Map<String, int> stock = {};
      if (stockData is Map<String, dynamic>) {
         stockData.forEach((key, value) {
          stock[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
        });
      }
      return stock;
    }

    return BloodBank(
      id: json['_id'] ?? '',
      name: json['bloodBankName'] ?? json['hospitalName'] ?? 'Unknown Blood Bank',
      location: json['fullAddress'] ?? json['hospitalLocation'] ?? 'Unknown Location',
      distance: 0.0, // Default distance as backend doesn't provide it yet
      phone: json['phoneNumber'] ?? json['hospitalPhone'] ?? '',
      stock: parseStock(json['inventory']),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RequesterBloodBankScreen extends StatefulWidget {
  const RequesterBloodBankScreen({super.key});

  @override
  State<RequesterBloodBankScreen> createState() => _RequesterBloodBankScreenState();
}

class _RequesterBloodBankScreenState extends State<RequesterBloodBankScreen> {
  late Future<List<BloodBank>> _bloodBanksFuture;
  List<BloodBank> _allBloodBanks = [];
  List<BloodBank> _filteredBloodBanks = [];
  
  // Search controller removed as per request

  @override
  void initState() {
    super.initState();
    _bloodBanksFuture = _fetchBloodBanks();
  }

  Future<List<BloodBank>> _fetchBloodBanks() async {
    try {
      final data = await ApiService().getBloodBanks();
      // Debug print to see what data we get
      debugPrint('Blood Banks Data: $data');
      final banks = data.map((json) => BloodBank.fromJson(json)).toList();
      _allBloodBanks = banks;
      _filteredBloodBanks = banks;
      return banks;
    } catch (e) {
      debugPrint('Error fetching blood banks: $e');
      return [];
    }
  }

  // Filter logic removed

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
          // Search bar removed
          // Map preview removed
          _buildInfoBanner(),
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
                  return const Center(child: Text('No blood banks found.'));
                }

                // Always show all banks since filter is removed
                final displayBanks = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: displayBanks.length,
                  itemBuilder: (context, index) {
                    return BloodBankCard(bank: displayBanks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // _buildSearchBar removed
  // _buildMapPreview removed

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          if (_allBloodBanks.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BloodBankMapScreen(bloodBanks: _allBloodBanks),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No blood banks to show on map')),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'See in Maps',
                style: TextStyle(
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

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: Call ahead to confirm blood availability before visiting. Blood banks may have updated inventory.',
              style: TextStyle(color: Color(0xFF666666), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class BloodBankCard extends StatelessWidget {
  final BloodBank bank;
  const BloodBankCard({super.key, required this.bank});

  Color _getStockColor(int units) {
    if (units >= 10) return const Color(0xFF4CAF50); // Green
    if (units > 0) return const Color(0xFFFF9800); // Yellow
    if (units == 0) return const Color(0xFFF44336); // Red
    return const Color(0xFF9E9E9E); // Gray for not specified
  }

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

  Future<void> _openMap(BuildContext context) async {
    // If we have coordinates, use them for precise location
    if (bank.latitude != 0.0 && bank.longitude != 0.0) {
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BloodBankMapScreen(bloodBanks: [bank]),
          ),
        );
    } else {
      // Fallback to external map with query
      final Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(bank.location)}');
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps')),
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
            _buildCardHeader(context),
            const SizedBox(height: 12),
            const Text('Available Blood Units:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildStockGrid(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
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
        // Text('${bank.distance} km', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStockGrid() {
    if (bank.stock.isEmpty) {
      return const Text('No stock information available', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: bank.stock.length,
      itemBuilder: (context, index) {
        String bloodGroup = bank.stock.keys.elementAt(index);
        int units = bank.stock.values.elementAt(index);
        return Container(
          decoration: BoxDecoration(
            color: _getStockColor(units).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getStockColor(units)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(units >= 0 ? units.toString() : '-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _getStockColor(units))),
              Text(bloodGroup, style: TextStyle(fontSize: 12, color: _getStockColor(units).withOpacity(0.9))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: (bank.phone.isNotEmpty) ? () => _makePhoneCall(bank.phone) : null,
            icon: const Icon(Icons.call, size: 18),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _openDirections,
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('Directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
