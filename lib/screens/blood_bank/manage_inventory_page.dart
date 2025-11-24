import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

=======

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';

>>>>>>> map-feature
class ManageInventoryPage extends StatefulWidget {
  const ManageInventoryPage({super.key});

  @override
  State<ManageInventoryPage> createState() => _ManageInventoryPageState();
}

class _ManageInventoryPageState extends State<ManageInventoryPage> {
<<<<<<< HEAD
  late Future<Map<String, dynamic>> _profileFuture;
=======
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _initialized = false;
>>>>>>> map-feature

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      _profileFuture = ApiService().getBloodBankProfile(user.id!).then((data) => data as Map<String, dynamic>);
    } else {
      _profileFuture = Future.error('User not logged in');
=======
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
>>>>>>> map-feature
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
<<<<<<< HEAD
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading inventory: ${snapshot.error}'));
          }

          final profileData = snapshot.data;
          if (profileData == null) {
            return const Center(child: Text('No inventory data found'));
          }

          final inventory = Map<String, dynamic>.from(profileData['inventory'] ?? {});
          
          int totalUnits = 0;
          int expiringSoon = 0; 
          int bloodTypesCount = 0;

          final List<Map<String, dynamic>> stockItems = [];
          
          inventory.forEach((group, quantity) {
            final qty = (quantity as num).toInt();
            if (qty > 0) {
              totalUnits += qty;
              bloodTypesCount++;
              
              stockItems.add({
                'group': group,
                'quantity': qty,
                'status': qty < 10 ? 'Critical' : 'Fresh', 
              });
            }
          });
          
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // Removed Search Bar
              _buildInventoryOverview(totalUnits.toString(), expiringSoon.toString(), bloodTypesCount.toString()),
              // Removed Filter/Sort Bar (All Blood Groups)
              const SizedBox(height: 24),
              _buildStockItemsList(stockItems),
            ],
          );
        },
=======
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
>>>>>>> map-feature
      ),
    );
  }

  Widget _buildInventoryOverview(String total, String expiring, String types) {
    return Padding(
<<<<<<< HEAD
=======
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
>>>>>>> map-feature
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
<<<<<<< HEAD
          Expanded(child: _StatCard(value: total, label: 'Total Units', color: const Color(0xFF2196F3))),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(value: expiring, label: 'Expiring Soon', color: const Color(0xFFFF9800))),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(value: types, label: 'Blood Types', color: const Color(0xFF4CAF50))),
=======
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
>>>>>>> map-feature
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildStockItemsList(List<Map<String, dynamic>> stockItems) {
=======
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

>>>>>>> map-feature
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
           Text('Stock Items (${stockItems.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
           const SizedBox(height:12),
           if (stockItems.isEmpty)
             const Text("No stock items found."),
          ...stockItems.map((item) => _buildStockItemCard(item)).toList(),
=======
          Text(
            'Stock Items (${items.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...items.map((entry) => _buildStockItemCard(entry)).toList(),
>>>>>>> map-feature
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
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
<<<<<<< HEAD
            CircleAvatar(
              backgroundColor: statusColor, 
              radius: 24, 
              child: Text(item['group'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('${item['quantity']} Units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(item['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12))
                  )
                ]
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, color: Colors.grey)),
=======
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
>>>>>>> map-feature
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

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
>>>>>>> map-feature
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
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
=======
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
>>>>>>> map-feature
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
