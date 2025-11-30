import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class ManageInventoryPage extends StatefulWidget {
  const ManageInventoryPage({super.key});

  @override
  State<ManageInventoryPage> createState() => _ManageInventoryPageState();
}

class _ManageInventoryPageState extends State<ManageInventoryPage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.id != null) {
      _profileFuture = ApiService().getBloodBankProfile(user.id!).then((data) => data as Map<String, dynamic>);
    } else {
      _profileFuture = Future.error('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Inventory'),
            Text('Blood stock management', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
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

          final List<Map<String, dynamic>> stockItems = [];
          
          inventory.forEach((group, quantity) {
            final qty = (quantity as num).toInt();
            if (qty > 0) {
              totalUnits += qty;
              
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
              _buildInventoryOverview(totalUnits.toString()),
              const SizedBox(height: 24),
              _buildStockItemsList(stockItems),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInventoryOverview(String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _StatCard(value: total, label: 'Total Units', color: const Color(0xFF2196F3))),
        ],
      ),
    );
  }

  Widget _buildStockItemsList(List<Map<String, dynamic>> stockItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Stock Items (${stockItems.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
           const SizedBox(height:12),
           if (stockItems.isEmpty)
             const Text("No stock items found."),
          ...stockItems.map((item) => _buildStockItemCard(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildStockItemCard(Map<String, dynamic> item) {
    final statusColors = {'Fresh': Colors.green, 'Expiring Soon': Colors.orange, 'Critical': Colors.red};
    final statusColor = statusColors[item['status']] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
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
            // Removed the edit icon (pencil logo) as requested
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
