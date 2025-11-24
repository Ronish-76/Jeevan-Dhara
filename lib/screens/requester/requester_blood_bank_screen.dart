import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Data model for Blood Bank
class BloodBank {
  final String id;
  final String name;
  final String location;
  final double distance;
  final String phone;
  final Map<String, int> stock;

  BloodBank({
    required this.id,
    required this.name,
    required this.location,
    required this.distance,
    required this.phone,
    required this.stock,
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
    );
  }
}

class RequesterBloodBankScreen extends StatefulWidget {
  const RequesterBloodBankScreen({super.key});

  @override
  State<RequesterBloodBankScreen> createState() =>
      _RequesterBloodBankScreenState();
}

class _RequesterBloodBankScreenState extends State<RequesterBloodBankScreen> {
<<<<<<< HEAD
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
=======
  final List<BloodBank> _bloodBanks = [
    BloodBank(
      name: 'Central Blood Bank',
      location: 'Maharajgunj, Kathmandu',
      distance: 2.5,
      phone: '+977-1-4412303',
      stock: {
        'A+': 15,
        'O+': 8,
        'B+': 2,
        'AB+': 0,
        'A-': 5,
        'O-': 1,
        'B-': 12,
        'AB-': -1,
      },
    ),
    BloodBank(
      name: 'Red Cross Society',
      location: 'Kalimati, Kathmandu',
      distance: 4.2,
      phone: '+977-1-4270654',
      stock: {
        'A+': 5,
        'O+': 20,
        'B+': 10,
        'AB+': 3,
        'A-': 0,
        'O-': 6,
        'B-': 8,
        'AB-': 2,
      },
    ),
    BloodBank(
      name: 'Grande Hospital Bank',
      location: 'Tokha, Kathmandu',
      distance: 7.1,
      phone: '+977-1-5159266',
      stock: {
        'A+': 8,
        'O+': 12,
        'B+': 18,
        'AB+': 6,
        'A-': 3,
        'O-': 4,
        'B-': 0,
        'AB-': 1,
      },
    ),
  ];
>>>>>>> map-feature

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

<<<<<<< HEAD
  // _buildSearchBar removed
  // _buildMapPreview removed
=======
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFD32F2F),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const TextField(
          decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Search by name or location...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 150, // Static height for map preview
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF0F0F0), // Placeholder color
        image: const DecorationImage(
          image: NetworkImage(
            'https://i.stack.imgur.com/g216T.png',
          ), // Placeholder map image
          fit: BoxFit.cover,
        ),
      ),
    );
  }
>>>>>>> map-feature

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
            _buildCardHeader(),
            const SizedBox(height: 12),
            const Text(
              'Available Blood Units:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStockGrid(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.home_work_outlined,
          color: Color(0xFFD32F2F),
          size: 36,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bank.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bank.location,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
              const SizedBox(height: 4),
<<<<<<< HEAD
              if (bank.phone.isNotEmpty)
                Text(bank.phone, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
            ],
          ),
        ),
        // Text('${bank.distance} km', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w500)),
=======
              Text(
                bank.phone,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '${bank.distance} km',
          style: const TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.w500,
          ),
        ),
>>>>>>> map-feature
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
              Text(
                units >= 0 ? units.toString() : '-',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _getStockColor(units),
                ),
              ),
              Text(
                bloodGroup,
                style: TextStyle(
                  fontSize: 12,
                  color: _getStockColor(units).withOpacity(0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
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
            icon: const Icon(Icons.directions, size: 18),
            label: const Text('Directions'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
              side: const BorderSide(color: Color(0xFFD32F2F)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
