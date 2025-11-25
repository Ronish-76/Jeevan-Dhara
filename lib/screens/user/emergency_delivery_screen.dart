import 'package:flutter/material.dart';

class EmergencyDeliveryScreen extends StatelessWidget {
  const EmergencyDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: const Text('Emergency Delivery'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.emergency_share_outlined)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildUrgentActions(),
            _buildDeliveryTimeline(),
            _buildInfoCards(),
            _buildDeliveryDetailsGrid(),
            const SizedBox(height: 20),
            _buildBottomButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFD32F2F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text('REG-0044-FG7', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          SizedBox(height: 8),
          Text('Delivery in Progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('ETA: 15 minutes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('5.2 km away', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildUrgentActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Urgent Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(icon: Icons.phone, label: 'Call Driver', isPrimary: true),
              _buildActionButton(icon: Icons.report_problem_outlined, label: 'Report Issue'),
              _buildActionButton(icon: Icons.cancel_outlined, label: 'Cancel'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, bool isPrimary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: isPrimary
            ? ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(icon, size: 18),
                label: Expanded(child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              )
            : OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(icon, size: 18),
                label: Expanded(child: Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F), side: const BorderSide(color: Color(0xFFD32F2F)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
      ),
    );
  }

  Widget _buildDeliveryTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildTimelineStep('Picked Up', 'Blood collected from donor', '2:15 PM', isCompleted: true, isCurrent: false),
          _buildTimelineConnector(),
          _buildTimelineStep('In Transit', 'On the way to hospital', '2:28 PM', isCompleted: false, isCurrent: true),
          _buildTimelineConnector(),
          _buildTimelineStep('Delivered', 'Blood delivered successfully', 'ETA: 2:45 PM', isCompleted: false, isCurrent: false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, String time, {required bool isCompleted, required bool isCurrent}) {
    Color circleColor = isCompleted ? const Color(0xFF4CAF50) : (isCurrent ? const Color(0xFFF44336) : const Color(0xFF9E9E9E));
    IconData icon = isCompleted ? Icons.check : (isCurrent ? Icons.local_shipping : Icons.pending_actions);

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCurrent ? circleColor : Colors.black87)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      height: 20,
      width: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
    );
  }

  Widget _buildInfoCards() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildInfoCard('Donor Information', Icons.person, 'Rajesh Thapa', 'Banashwor, Kathmandu')),
          const SizedBox(width: 16),
          Expanded(child: _buildInfoCard('Hospital Information', Icons.local_hospital, 'Teaching Hospital', 'Mushangpur, Kathmandu')),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String name, String location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 18, color: const Color(0xFFD32F2F)), const SizedBox(width: 8), Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)))]),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Flexible(child: Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)))]),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetailsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5, // Adjust for content
        children: [
          _buildDetailItem('Blood Group', 'O+', isBadge: true),
          _buildDetailItem('Units', '2 units'),
          _buildDetailItem('Distance', '5.2 km'),
          _buildDetailItem('ETA', '15 minutes'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isBadge = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          const SizedBox(height: 4),
          isBadge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFD32F2F), borderRadius: BorderRadius.circular(12)),
                  child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
              : Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone),
                label: const Text("Call Driver"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.report),
                label: const Text("Report Issue"),
                style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD32F2F), side: const BorderSide(color: Color(0xFFD32F2F)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
          ),
        ],
      ),
    );
  }
}
