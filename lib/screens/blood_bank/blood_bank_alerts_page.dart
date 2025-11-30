import 'package:flutter/material.dart';
import 'package:jeevandhara/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class BloodBankAlertsPage extends StatefulWidget {
  const BloodBankAlertsPage({super.key});

  @override
  State<BloodBankAlertsPage> createState() => _BloodBankAlertsPageState();
}

class _BloodBankAlertsPageState extends State<BloodBankAlertsPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _lowStockAlerts = [];
  List<Map<String, dynamic>> _requestAlerts = [];
  List<Map<String, dynamic>> _deliveryAlerts = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 1. Fetch Inventory for Low Stock
      final profile = await ApiService().getBloodBankProfile(user.id!);
      final inventory = Map<String, dynamic>.from(profile['inventory'] ?? {});
      
      // 2. Fetch Requests
      final requests = await ApiService().getBloodBankRequests(user.id!);
      
      // 3. Fetch Distributions (Deliveries)
      final distributions = await ApiService().getDistributions(user.id!);

      if (mounted) {
        _processData(inventory, requests, distributions);
        setState(() => _isLoading = false);
      }

    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processData(Map<String, dynamic> inventory, List<dynamic> requests, List<dynamic> distributions) {
    final List<Map<String, dynamic>> lowStock = [];
    final List<Map<String, dynamic>> reqAlerts = [];
    final List<Map<String, dynamic>> delAlerts = [];
    final now = DateTime.now();

    // Process Inventory
    inventory.forEach((group, units) {
      final count = (units as num).toInt();
      if (count < 5) {
        lowStock.add({
          'title': 'Critical Low Stock: $group',
          'description': 'Only $count units remaining. Immediate action required.',
          'time': 'Now',
          'priority': 'critical'
        });
      } else if (count < 10) {
        lowStock.add({
          'title': 'Low Stock Warning: $group',
          'description': '$count units remaining. Consider organizing a drive.',
          'time': 'Now',
          'priority': 'warning'
        });
      }
    });

    // Process Requests
    for (var req in requests) {
      if (req['status'] == 'pending') {
        final hospitalObj = req['hospital'];
        final hospitalName = hospitalObj is Map ? (hospitalObj['hospitalName'] ?? 'Unknown') : 'Unknown Hospital';
        final timeAgo = _formatTimeAgo(req['createdAt']);
        
        reqAlerts.add({
          'title': 'New Blood Request',
          'description': '$hospitalName requested ${req['unitsRequired'] ?? req['units']} units of ${req['bloodGroup']}.',
          'time': timeAgo,
        });
      }
    }

    // Process Distributions (Completed Deliveries)
    // Sort by latest first (already sorted by API but to be safe/flexible)
    // Take top 5 recent
    for (var dist in distributions.take(5)) {
      final hospitalName = dist['hospitalName'] ?? 'Unknown Hospital';
      final timeAgo = _formatTimeAgo(dist['dispatchDate']);
      
      delAlerts.add({
        'title': 'Delivery Completed',
        'description': '${dist['units']} units of ${dist['bloodGroup']} dispatched to $hospitalName.',
        'time': timeAgo,
      });
    }

    _lowStockAlerts = lowStock;
    _requestAlerts = reqAlerts;
    _deliveryAlerts = delAlerts;
  }

  String _formatTimeAgo(dynamic dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(date);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAlerts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
            : _lowStockAlerts.isEmpty && _requestAlerts.isEmpty && _deliveryAlerts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(
                        height: 500,
                        child: Center(child: Text('No new alerts', style: TextStyle(color: Colors.grey))),
                      )
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_lowStockAlerts.isNotEmpty)
                        _buildAlertsSection(
                          title: 'Inventory Alerts',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFF44336),
                          alerts: _lowStockAlerts,
                        ),
                      if (_requestAlerts.isNotEmpty)
                        _buildAlertsSection(
                          title: 'Pending Requests',
                          icon: Icons.assignment_late_outlined,
                          color: const Color(0xFFFF9800),
                          alerts: _requestAlerts,
                        ),
                      if (_deliveryAlerts.isNotEmpty)
                        _buildAlertsSection(
                          title: 'Recent Deliveries',
                          icon: Icons.local_shipping_outlined,
                          color: const Color(0xFF4CAF50),
                          alerts: _deliveryAlerts,
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAlertsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> alerts,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...alerts.map((alert) => _buildAlertItem(alert)).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(alert['description'], style: const TextStyle(color: Colors.black87, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(alert['time'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
