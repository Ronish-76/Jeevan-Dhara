import 'package:flutter/material.dart';

// Data model for Blood Bank
class BloodBank {
  final String name;
  final String location;
  final double distance;
  final String phone;
  final Map<String, int> stock;

  BloodBank({
    required this.name,
    required this.location,
    required this.distance,
    required this.phone,
    required this.stock,
  });
}

class BloodBankPage extends StatefulWidget {
  const BloodBankPage({super.key});

  @override
  State<BloodBankPage> createState() => _BloodBankPageState();
}

class _BloodBankPageState extends State<BloodBankPage> {
  final List<BloodBank> _bloodBanks = [
    BloodBank(name: 'Central Blood Bank', location: 'Maharajgunj, Kathmandu', distance: 2.5, phone: '+977-1-4412303', stock: {'A+': 15, 'O+': 8, 'B+': 2, 'AB+': 0, 'A-': 5, 'O-': 1, 'B-': 12, 'AB-': -1}),
    BloodBank(name: 'Red Cross Society', location: 'Kalimati, Kathmandu', distance: 4.2, phone: '+977-1-4270654', stock: {'A+': 5, 'O+': 20, 'B+': 10, 'AB+': 3, 'A-': 0, 'O-': 6, 'B-': 8, 'AB-': 2}),
    BloodBank(name: 'Grande Hospital Bank', location: 'Tokha, Kathmandu', distance: 7.1, phone: '+977-1-5159266', stock: {'A+': 8, 'O+': 12, 'B+': 18, 'AB+': 6, 'A-': 3, 'O-': 4, 'B-': 0, 'AB-': 1}),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Blood Banks'),
            Text(
              '${_bloodBanks.length} blood banks nearby',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildMapPreview(),
          _buildInfoBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bloodBanks.length,
              itemBuilder: (context, index) {
                return BloodBankCard(bank: _bloodBanks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

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
          image: NetworkImage('https://i.stack.imgur.com/g216T.png'), // Placeholder map image
          fit: BoxFit.cover,
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
            const Text('Available Blood Units:', style: TextStyle(fontWeight: FontWeight.bold)),
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
              Text(bank.phone, style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
            ],
          ),
        ),
        Text('${bank.distance} km', style: const TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStockGrid() {
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
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
            onPressed: () {},
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
