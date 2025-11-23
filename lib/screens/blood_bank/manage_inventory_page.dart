import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';

class ManageInventoryPage extends StatefulWidget {
  const ManageInventoryPage({super.key});

  @override
  State<ManageInventoryPage> createState() => _ManageInventoryPageState();
}

class _ManageInventoryPageState extends State<ManageInventoryPage> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final inventoryViewModel = context.read<InventoryViewModel>();
    if (inventoryViewModel.nearbyFacilities.isEmpty) {
      await inventoryViewModel.fetchNearbyFacilities(role: UserRole.bloodBank);
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final facility = inventoryViewModel.nearbyFacilities.isNotEmpty
        ? inventoryViewModel.nearbyFacilities.first
        : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Inventory'),
            Text(
              'Blood stock management',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            _buildSearchBar(),
            _buildInventoryOverview(facility, inventoryViewModel),
            _buildFilterAndSortBar(),
            const SizedBox(height: 16),
            _buildStockItemsList(facility, inventoryViewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by blood group...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryOverview(facility, InventoryViewModel provider) {
    final inventory = facility?.inventory ?? {};
    final totalUnits = inventory.values.fold<int>(
      0,
      (sum, units) => sum + units,
    );
    final bloodTypes = inventory.keys.length;
    final lowStock = inventory.entries.where((e) => e.value < 10).length;

    if (provider.isLoading && inventory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _StatCard(
              value: totalUnits.toString(),
              label: 'Total Units',
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: lowStock.toString(),
              label: 'Low Stock',
              color: const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: bloodTypes.toString(),
              label: 'Blood Types',
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Chip(
            label: const Text('All Blood Groups'),
            backgroundColor: const Color(0xFFD32F2F),
            labelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
    );
  }

  Widget _buildStockItemsList(facility, InventoryViewModel provider) {
    final inventory = facility?.inventory ?? {};
    if (provider.isLoading && inventory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (inventory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text('No inventory data available')),
      );
    }

    var items = inventory.entries.toList();
    if (_searchQuery.isNotEmpty) {
      items = items
          .where(
            (e) => e.key.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Items (${items.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...items.map((entry) => _buildStockItemCard(entry)).toList(),
        ],
      ),
    );
  }

  Widget _buildStockItemCard(MapEntry<String, int> entry) {
    final statusColors = {
      'Fresh': Colors.green,
      'Low': Colors.orange,
      'Critical': Colors.red,
    };
    String status;
    Color statusColor;
    if (entry.value < 5) {
      status = 'Critical';
      statusColor = statusColors['Critical']!;
    } else if (entry.value < 15) {
      status = 'Low';
      statusColor = statusColors['Low']!;
    } else {
      status = 'Fresh';
      statusColor = statusColors['Fresh']!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor,
                  radius: 20,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.value} Units',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.bloodtype, 'Blood Type', entry.key),
            _buildDetailRow(
              Icons.inventory_2_outlined,
              'Available Units',
              entry.value.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
