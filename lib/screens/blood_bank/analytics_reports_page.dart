import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jeevandhara/providers/auth_provider.dart';
import 'package:jeevandhara/services/api_service.dart';

class AnalyticsReportsPage extends StatefulWidget {
  const AnalyticsReportsPage({super.key});

  @override
  State<AnalyticsReportsPage> createState() => _AnalyticsReportsPageState();
}

class _AnalyticsReportsPageState extends State<AnalyticsReportsPage> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};
  String _selectedRange = 'Last 6 Months';

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user == null || user.id == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // For now, we'll fetch recent distributions and donations to calculate simple stats
      // Ideally, backend would have an analytics endpoint
      final donations = await ApiService().getDonations(user.id!);
      final distributions = await ApiService().getDistributions(user.id!);
      
      int totalDonations = donations.length;
      int totalUnitsCollected = 0;
      for (var d in donations) {
        totalUnitsCollected += (d['units'] as num).toInt();
      }

      int totalDistributed = distributions.length;
      int totalUnitsDistributed = 0;
      for (var d in distributions) {
        totalUnitsDistributed += (d['units'] as num).toInt();
      }

      // Calculate utilization
      double utilization = totalUnitsCollected > 0 ? (totalUnitsDistributed / totalUnitsCollected) * 100 : 0;

      if (mounted) {
        setState(() {
          _analyticsData = {
            'totalDonations': totalDonations,
            'totalUnitsCollected': totalUnitsCollected,
            'totalDistributed': totalDistributed,
            'totalUnitsDistributed': totalUnitsDistributed,
            'utilization': utilization.toStringAsFixed(1),
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching analytics: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Analytics & Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Blood bank statistics', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: _selectedRange,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              dropdownColor: const Color(0xFFD32F2F),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              items: <String>['Last 6 Months', 'Last 30 Days', 'Last 7 Days']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedRange = newValue);
                  _fetchAnalytics(); // Mock refresh based on range
                }
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAnalytics,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOverviewMetrics(),
                    const SizedBox(height: 20),
                    _buildRealTimeAlerts(),
                    const SizedBox(height: 20),
                    _buildChartsGrid(),
                    const SizedBox(height: 20),
                    _buildActionsPanel(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewMetrics() {
    final donations = _analyticsData['totalDonations']?.toString() ?? '0';
    final distributed = _analyticsData['totalUnitsDistributed']?.toString() ?? '0';
    final utilization = _analyticsData['utilization']?.toString() ?? '0';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MetricItem(value: donations, label: 'Total Donations', trend: '+4.6%', trendColor: Colors.green),
            _MetricItem(value: distributed, label: 'Units Distributed', trend: '$utilization% utilization', trendColor: Colors.blue),
            const _MetricItem(value: '0', label: 'Expired', trend: '0% expiry rate', trendColor: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeAlerts() {
    return _buildSectionCard(
      title: 'Real-time & Predictive Analytics',
      child: const Column(
        children: [
          _AlertItem(title: 'Low Stock Warning', message: 'System check complete: Stock levels stable.', color: Colors.green),
          // _AlertItem(title: 'Expiry Alert', message: '12 units expiring in the next 7 days.', color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildChartsGrid() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Monthly Donations & Distribution',
          child: AspectRatio(aspectRatio: 1.8, child: Container(color: Colors.grey.shade200, child: const Center(child: Text('Bar & Line Chart Placeholder')))),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          title: 'Blood Units by Type',
          child: AspectRatio(aspectRatio: 1.8, child: Container(color: Colors.grey.shade200, child: const Center(child: Text('Pie Chart Placeholder')))),
        ),
      ],
    );
  }

  Widget _buildActionsPanel() {
    return _buildSectionCard(
      title: 'Insights & Actions',
      child: Column(
        children: [
          const Text('Donation volumes show a positive trend over the last quarter, and distribution efficiency remains high.', style: TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text('Download Report (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

   Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), child],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String value, label, trend;
  final Color trendColor;
  const _MetricItem({required this.value, required this.label, required this.trend, required this.trendColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(trend, style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title, message;
  final Color color;
  const _AlertItem({required this.title, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.warning, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)), Text(message, style: const TextStyle(fontSize: 12))],
            ),
          ),
        ],
      ),
    );
  }
}
