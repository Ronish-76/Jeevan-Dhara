import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalRequestMapScreen extends StatefulWidget {
  final String? facilityId;
  final String? facilityName;

  const HospitalRequestMapScreen({
    super.key,
    this.facilityId,
    this.facilityName,
  });

  @override
  State<HospitalRequestMapScreen> createState() =>
      _HospitalRequestMapScreenState();
}

class _HospitalRequestMapScreenState extends State<HospitalRequestMapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facilityName ?? 'Hospital Map'),
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
              'Map integration with ${widget.facilityName ?? 'facility'}',
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
