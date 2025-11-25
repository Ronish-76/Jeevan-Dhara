import 'package:flutter/material.dart';

class HospitalManageStockPage extends StatelessWidget {
  const HospitalManageStockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Manage Blood Stock'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQuickStats(),
            _buildCriticalAlertBanner(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [Icon(Icons.inventory_2_outlined), SizedBox(width: 8), Text('Blood Type Inventory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))],),),            
            _buildInventoryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: const Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _StatCard(value: '96', label: 'Total Units', color: Color(0xFF2196F3)),
          _StatCard(value: '3', label: 'Low Stock', color: Color(0xFFFF9800)),
          _StatCard(value: '2', label: 'Critical', color: Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF44336).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(child: Text('2 blood types are at critical levels', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () {}, child: const Text('View', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }

  Widget _buildInventoryGrid() {
    final inventory = [
      {'group': 'A+', 'units': 24, 'min': 15, 'status': 'Sufficient', 'color': Colors.green},
      {'group': 'A-', 'units': 8, 'min': 10, 'status': 'Low', 'color': Colors.orange},
      {'group': 'B+', 'units': 18, 'min': 15, 'status': 'Sufficient', 'color': Colors.green},
      {'group': 'B-', 'units': 5, 'min': 10, 'status': 'Critical', 'color': Colors.red},
      {'group': 'O+', 'units': 32, 'min': 20, 'status': 'Sufficient', 'color': Colors.green},
      {'group': 'O-', 'units': 3, 'min': 10, 'status': 'Critical', 'color': Colors.red},
      {'group': 'AB+', 'units': 5, 'min': 5, 'status': 'Sufficient', 'color': Colors.green},
      {'group': 'AB-', 'units': 2, 'min': 5, 'status': 'Low', 'color': Colors.orange},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 200, // Generous fixed height to prevent any overflow
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: inventory.length,
      itemBuilder: (context, index) {
        return _buildBloodStockCard(inventory[index]);
      },
    );
  }

  Widget _buildBloodStockCard(Map<String, dynamic> stock) {
    final double stockLevel = (stock['units'] as int) / ((stock['min'] as int) * 1.5);
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: stock['color'], width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock['group'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: stock['color'])) ,
                const SizedBox(height: 4),
                Text(stock['status'], style: TextStyle(color: stock['color'], fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${stock['units']} units', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text('Min: ${stock['min']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: stockLevel, backgroundColor: Colors.grey.shade300, color: stock['color']),
              ],
            ),
            const Spacer(),
             Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {},
                  child: const Icon(Icons.remove_circle, size: 28, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {},
                  child: const Icon(Icons.add_circle, size: 28, color: Colors.grey),
                ),
              ],
            )
          ],
        ));
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
