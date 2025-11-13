import 'package:flutter/material.dart';

class ManageInventoryPage extends StatelessWidget {
  const ManageInventoryPage({super.key});

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
      body: ListView(
        children: [
          _buildSearchBar(),
          _buildInventoryOverview(),
          _buildFilterAndSortBar(),
          const SizedBox(height: 16),
          _buildStockItemsList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by blood group, batch, or donor...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildInventoryOverview() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _StatCard(value: '158', label: 'Total Units', color: Color(0xFF2196F3))),
          SizedBox(width: 12),
          Expanded(child: _StatCard(value: '7', label: 'Expiring Soon', color: Color(0xFFFF9800))),
          SizedBox(width: 12),
          Expanded(child: _StatCard(value: '8', label: 'Blood Types', color: Color(0xFF4CAF50))),
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
            labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
    );
  }

  Widget _buildStockItemsList() {
    final stockItems = [
      {'group': 'A-', 'quantity': 8, 'status': 'Fresh', 'batchId': 'BB-B-604', 'donor': 'Maya Gurung', 'expiry': 38},
      {'group': 'O+', 'quantity': 12, 'status': 'Expiring Soon', 'batchId': 'BB-O-112', 'donor': 'Hari Thapa', 'expiry': 15},
      {'group': 'AB-', 'quantity': 2, 'status': 'Critical', 'batchId': 'BB-AB-98', 'donor': 'Gita Sedai', 'expiry': 4},
       {'group': 'B+', 'quantity': 20, 'status': 'Fresh', 'batchId': 'BB-B-781', 'donor': 'Ram KC', 'expiry': 45},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:16.0),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text('Stock Items (16)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
           const SizedBox(height:8),
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: statusColor, radius: 20, child: Text(item['group'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${item['quantity']} Units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(item['status'], style: TextStyle(color: statusColor, fontWeight: FontWeight.w500, fontSize: 12))]),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.grey)),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(Icons.person_outline, 'Donor', item['donor']),
            _buildDetailRow(Icons.inventory_2_outlined, 'Batch ID', item['batchId']),
            _buildDetailRow(Icons.calendar_today_outlined, 'Expiry', '${item['expiry']} days left'),
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
          Text('$label:', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
