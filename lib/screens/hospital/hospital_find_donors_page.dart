import 'package:flutter/material.dart';

class HospitalFindDonorsPage extends StatefulWidget {
  const HospitalFindDonorsPage({super.key});

  @override
  State<HospitalFindDonorsPage> createState() => _HospitalFindDonorsPageState();
}

class _HospitalFindDonorsPageState extends State<HospitalFindDonorsPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Find Donors Nearby'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildResultsSummary(),
          Expanded(
            child: _buildDonorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by name...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'A+', 'B+', 'O+', 'AB+', 'Available'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedFilter = selected ? filter : 'All'),
              selectedColor: filter == 'Available' ? Colors.green : const Color(0xFFD32F2F),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12),
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildResultsSummary() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text('Showing 8 donors within 5 km radius', style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  Widget _buildDonorsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildSectionHeader('Available Donors', Icons.check_circle, Colors.green),
                _buildDonorCard('Rajesh Kumar', '1.2 km away', 12, 3, true),
                _buildDonorCard('Anjali Gurung', '2.5 km away', 1, 2, true),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                _buildSectionHeader('Not Available', Icons.cancel, Colors.grey),
                _buildDonorCard('Sunita Sharma', '4.1 km away', 2, 1, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildDonorCard(String name, String distance, int donations, int lastDonationMonths, bool isAvailable) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(distance, style: const TextStyle(fontSize: 11, color: Colors.grey))]),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.military_tech_outlined, size: 12, color: Colors.grey), const SizedBox(width: 4), Text('$donations donations', style: const TextStyle(fontSize: 11, color: Colors.grey))]),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey), const SizedBox(width: 4), Text('Last: $lastDonationMonths months ago', style: const TextStyle(fontSize: 11, color: Colors.grey))]),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAvailable ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable ? const Color(0xFF4CAF50) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)
                  ),
                  child: Text(isAvailable ? 'Request Now' : 'Unavailable'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
