import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/blood_request_model.dart';
import '../../viewmodels/donor_viewmodel.dart';
import 'donor_request_details_page.dart';

class DonorRequestsPage extends StatefulWidget {
  const DonorRequestsPage({super.key});

  @override
  State<DonorRequestsPage> createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage> {
  String? _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonorViewModel>().loadUrgentRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DonorViewModel>();
    final requests = provider.urgentRequests.where((request) {
      if (_selectedBloodGroup == null) return true;
      return request.bloodType == _selectedBloodGroup;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Nearby Blood Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DonorViewModel>().loadUrgentRequests(
              bloodType: _selectedBloodGroup,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search by city or blood group',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<DonorViewModel>().loadUrgentRequests(
          bloodType: _selectedBloodGroup,
        ),
        child: Column(
          children: [
            _buildFilterChips(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    provider.isLoading
                        ? 'Loading requests near you'
                        : '${requests.length} requests found near you',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && requests.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : requests.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No requests at the moment. Pull to refresh.',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(requests[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final bloodGroups = ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: 35,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bloodGroups.length,
          itemBuilder: (context, index) {
            final group = bloodGroups[index];
            final isSelected = _selectedBloodGroup == group;
            return ChoiceChip(
              label: Text(group),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedBloodGroup = selected ? group : null;
                });
                context.read<DonorViewModel>().loadUrgentRequests(
                  bloodType: selected ? group : null,
                );
              },
              selectedColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: const Color(0xFFF0F0F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide.none,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequestModel request) {
    final urgencyColor = request.urgency == 'critical'
        ? const Color(0xFFB71C1C)
        : const Color(0xFFD32F2F);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonorRequestDetailsPage(request: request),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: urgencyColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: urgencyColor.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    request.bloodType,
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requesterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.locationName ?? 'Shared location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.createdAt != null
                              ? request.createdAt!.toLocal().toString().split('.').first
                              : 'Date unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonorRequestDetailsPage(request: request),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Text('I Can Help', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
