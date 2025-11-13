import 'package:flutter/material.dart';
import 'package:jeevandhara/screens/donor/donor_request_details_page.dart';

class DonorRequestsPage extends StatefulWidget {
  const DonorRequestsPage({super.key});

  @override
  State<DonorRequestsPage> createState() => _DonorRequestsPageState();
}

class _DonorRequestsPageState extends State<DonorRequestsPage> {
  String? _selectedBloodGroup;

  final List<BloodRequest> _requests = [
    const BloodRequest(patientName: 'Sita Sharma', hospitalName: 'Bir Hospital, Kathmandu', bloodGroup: 'O+', urgency: 'Critical', distance: '1.2 km', time: '30 min ago', urgencyColor: Color(0xFFB71C1C)),
    const BloodRequest(patientName: 'Arjun Yadav', hospitalName: 'Civil Hospital', bloodGroup: 'A-', urgency: 'Urgent', distance: '3.5 km', time: '2 hours ago', urgencyColor: Color(0xFFFF9800)),
    const BloodRequest(patientName: 'Maya Gurung', hospitalName: 'National Medical College', bloodGroup: 'B+', urgency: 'Normal', distance: '5.1 km', time: 'Today', urgencyColor: Color(0xFF2196F3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Nearby Blood Requests'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
      body: Column(
        children: [
          _buildFilterChips(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text('${_requests.length} requests found near you', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(_requests[index]);
              },
            ),
          ),
        ],
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
              },
              selectedColor: const Color(0xFFD32F2F),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              backgroundColor: const Color(0xFFF0F0F0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            );
          },
          separatorBuilder: (context, index) => const SizedBox(width: 8),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequest request) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DonorRequestDetailsPage(request: request)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: request.urgencyColor, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(shape: BoxShape.circle, color: request.urgencyColor.withOpacity(0.1)),
                child: Center(child: Text(request.bloodGroup, style: TextStyle(color: request.urgencyColor, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.patientName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Expanded(child: Text(request.hospitalName, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(request.distance, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                    const SizedBox(height: 4),
                    Row(children: [const Icon(Icons.access_time, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(request.time, style: const TextStyle(fontSize: 12, color: Colors.grey))]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                child: const Text('I Can Help', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
