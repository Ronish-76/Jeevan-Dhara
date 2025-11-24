import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/location_model.dart';
import '../../viewmodels/inventory_viewmodel.dart';

class HospitalManageStockPage extends StatefulWidget {
  const HospitalManageStockPage({super.key});

  @override
  State<HospitalManageStockPage> createState() =>
      _HospitalManageStockPageState();
}

class _HospitalManageStockPageState extends State<HospitalManageStockPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<InventoryViewModel>().fetchNearbyFacilities(
      role: UserRole.hospital,
      radiusKm: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryViewModel = context.watch<InventoryViewModel>();
    final facility = _selectFacility(inventoryViewModel);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Manage Blood Stock'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildQuickStats(facility, inventoryViewModel.isLoading),
              _buildCriticalAlertBanner(facility, inventoryViewModel.isLoading),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Blood Type Inventory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildInventoryGrid(facility, inventoryViewModel.isLoading),
            ],
          ),
        ),
      ),
    );
  }

  LocationModel? _selectFacility(InventoryViewModel provider) {
    if (provider.nearbyFacilities.isEmpty) return null;
    return provider.nearbyFacilities.firstWhere(
      (f) => f.inventory != null && f.inventory!.isNotEmpty,
      orElse: () => provider.nearbyFacilities.first,
    );
  }

  Widget _buildQuickStats(LocationModel? facility, bool loading) {
    final inventory = facility?.inventory;
    if (loading && (inventory == null || inventory.isEmpty)) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final totalUnits =
        inventory?.values.fold<int>(0, (sum, units) => sum + units) ?? 0;
    final lowStock =
        inventory?.entries.where((entry) => entry.value < 10).length ?? 0;
    final critical =
        inventory?.entries.where((entry) => entry.value < 5).length ?? 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          _StatCard(
            value: '$totalUnits',
            label: 'Total Units',
            color: Color(0xFF2196F3),
          ),
          _StatCard(
            value: '$lowStock',
            label: 'Low Stock',
            color: Color(0xFFFF9800),
          ),
          _StatCard(
            value: '$critical',
            label: 'Critical',
            color: Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalAlertBanner(LocationModel? facility, bool isLoading) {
    final critical =
        facility?.inventory?.entries
            .where((entry) => entry.value < 5)
            .toList() ??
        [];
    if (isLoading && critical.isEmpty) {
      return const SizedBox.shrink();
    }
    if (critical.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Expanded(
            child: Text(
              '${critical.length} blood types are at critical levels',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('View', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryGrid(LocationModel? facility, bool loading) {
    final inventory = facility?.inventory;
    if (loading && (inventory == null || inventory.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (inventory == null || inventory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Text('Inventory data not available.'),
      );
    }

    final items = inventory.entries
        .map(
          (entry) => {
            'group': entry.key,
            'units': entry.value,
            'min': 10,
            'status': _statusLabel(entry.value),
            'color': _statusColor(entry.value),
          },
        )
        .toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 200,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildBloodStockCard(items[index]);
      },
    );
  }

  Widget _buildBloodStockCard(Map<String, dynamic> stock) {
    final double stockLevel =
        (stock['units'] as int) / ((stock['min'] as int) * 1.5);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: stock['color'], width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock['group'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: stock['color'],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stock['status'],
                style: TextStyle(
                  color: stock['color'],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stock['units']} units',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Min: ${stock['min']}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: stockLevel,
                backgroundColor: Colors.grey.shade300,
                color: stock['color'],
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {},
                child: const Icon(
                  Icons.remove_circle,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {},
                child: const Icon(
                  Icons.add_circle,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _statusLabel(int units) {
  if (units < 5) return 'Critical';
  if (units < 15) return 'Low';
  return 'Sufficient';
}

Color _statusColor(int units) {
  if (units < 5) return Colors.red;
  if (units < 15) return Colors.orange;
  return Colors.green;
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
