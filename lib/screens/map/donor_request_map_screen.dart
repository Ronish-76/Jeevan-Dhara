import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DonorRequestMapScreen extends StatefulWidget {
  final String? donorId;
  final String? donorName;
  final String? donorBloodType;

  const DonorRequestMapScreen({
    super.key,
    this.donorId,
    this.donorName,
    this.donorBloodType,
  });

  @override
  State<DonorRequestMapScreen> createState() => _DonorRequestMapScreenState();
}

class _DonorRequestMapScreenState extends State<DonorRequestMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Map'),
        backgroundColor: const Color(0xFFD32F2F),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Map View',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Blood Type: ${widget.donorBloodType ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
