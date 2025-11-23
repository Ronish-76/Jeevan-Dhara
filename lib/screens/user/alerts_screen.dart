import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/blood_request_viewmodel.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<String> _filters = ['All', 'Pending', 'Responded'];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BloodRequestViewModel>().fetchActiveRequests(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BloodRequestViewModel>();
    final requests = provider.requests.where(_applyFilter).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('My Alerts'),
        actions: [
          IconButton(
            onPressed: () => provider.fetchActiveRequests(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final selected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedFilter = filter),
                      selectedColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected
                            ? const Color(0xFFD32F2F)
                            : Colors.white,
                      ),
                      backgroundColor: selected
                          ? Colors.white
                          : const Color(0xFFC62828),
                      side: BorderSide(
                        color: selected
                            ? const Color(0xFFD32F2F)
                            : Colors.transparent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: provider.isLoading && requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (_, index) {
                final request = requests[index];
                return _buildAlertCard(
                  title: '${request.bloodType} • ${request.units} units',
                  message: request.notes ?? 'Awaiting donor confirmation',
                  time: _formatTimestamp(request.createdAt ?? DateTime.now()),
                  priorityColor: request.status == 'responded'
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFD32F2F),
                  action: request.status == 'responded'
                      ? 'View Responder'
                      : 'Manage Request',
                );
              },
            ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required String time,
    required Color priorityColor,
    String? action,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: priorityColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
            if (action != null)
              TextButton(
                onPressed: () {},
                child: Text(
                  action,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _applyFilter(BloodRequestModel model) {
    switch (_selectedFilter) {
      case 'Pending':
        return model.status == 'pending';
      case 'Responded':
        return model.status == 'responded';
      default:
        return true;
    }
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hrs ago';
    return '${difference.inDays} days ago';
  }
}
