import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('My Alerts'),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_active))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Urgent', 'Donors', 'Delivery'].map((filter) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: filter == 'All', // Static selection for UI
                      onSelected: (selected) {},
                      selectedColor: Colors.white,
                      labelStyle: const TextStyle(color: Color(0xFFD32F2F)),
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF9F9F9),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Urgent Actions Needed', Icons.warning, color: const Color(0xFFD32F2F)),
          _buildAlertCard(
            title: 'Request Expiring Soon',
            message: 'Your O+ request expires in 2 hours. Consider extending it.',
            time: '15 min ago',
            priorityColor: const Color(0xFFD32F2F),
            action: 'Extend Request',
          ),
          _buildSectionHeader('Donor Responses', Icons.people_outline),
          _buildDonorResponseCard(),
          _buildSectionHeader('Delivery Updates', Icons.local_shipping_outlined),
          _buildAlertCard(
            title: 'Delivery in Progress',
            message: 'Emergency delivery REG-0044-FG7 started. ETA: 15 minutes.',
            time: '30 min ago',
            priorityColor: Colors.blue,
            action: 'Track Live',
          ),
          _buildSectionHeader('Recently Completed', Icons.check_circle_outline),
           _buildAlertCard(
            title: 'Request Fulfilled',
            message: 'Your O+ blood request was successfully fulfilled.',
            time: 'Yesterday',
            priorityColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color color = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildAlertCard({required String title, required String message, required String time, required Color priorityColor, String? action}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(message, style: const TextStyle(color: Colors.black87, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
            if (action != null)
              TextButton(
                onPressed: () {},
                child: Text(action, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonorResponseCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFFF9800), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFD32F2F),
                  child: Text('RT', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rajesh Thapa', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                         Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
                          child: const Text('O+', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        const Text('2.3 km away', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(onPressed: () {}, child: const Text('Confirm', style: TextStyle(color: Color(0xFF4CAF50)))),
                TextButton(onPressed: () {}, child: const Text('Contact', style: TextStyle(color: Color(0xFF2196F3)))),
                TextButton(onPressed: () {}, child: const Text('View Profile')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
