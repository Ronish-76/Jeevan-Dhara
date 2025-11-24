// lib/screens/map/blood_bank_request_map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';// FIX: Import the necessary models and viewmodels.
import '../../models/blood_request_model.dart';
import '../../viewmodels/blood_request_viewmodel.dart';
import '../../widgets/empty_state_widget.dart';

class BloodBankRequestMapScreen extends StatefulWidget {
  final String? facilityId;
  final String? facilityName;

  const BloodBankRequestMapScreen({
    super.key,
    this.facilityId,
    this.facilityName,
  });

  @override
  State<BloodBankRequestMapScreen> createState() =>
      _BloodBankRequestMapScreenState();
}

class _BloodBankRequestMapScreenState extends State<BloodBankRequestMapScreen> {
  // A default camera position for the map (e.g., Kathmandu)
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(27.7172, 85.3240),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to fetch data after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Access the viewmodel and load the initial data.
      context.read<BloodRequestViewModel>().loadActiveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.facilityName ?? 'Blood Requests Map'),
        backgroundColor: const Color(0xFFD32F2F),
        actions: [
          // Add a refresh button to reload data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BloodRequestViewModel>().loadActiveRequests();
            },
          ),
        ],
      ),
      // FIX: Replace the placeholder body with a real map implementation.
      body: Consumer<BloodRequestViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.activeRequests.isEmpty) {
            // Show a loading indicator while fetching initial data.
            return const Center(child: CircularProgressIndicator());
          }

          if (!viewModel.isLoading && viewModel.activeRequests.isEmpty) {
            // Show a user-friendly message if no requests are found.
            return const EmptyStateWidget(
              icon: Icons.map_outlined,
              message: 'No active blood requests found nearby.',
            );
          }

          // If we have data, build the set of markers.
          final markers = _buildMarkers(viewModel.activeRequests);

          // Display the map with the markers.
          return GoogleMap(
            initialCameraPosition: _kInitialPosition,
            markers: markers,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          );
        },
      ),
    );
  }

  /// Helper method to convert a list of requests into a set of map markers.
  Set<Marker> _buildMarkers(List<BloodRequestModel> requests) {
    return requests.map((request) {
      return Marker(
        markerId: MarkerId(request.id),
        position: LatLng(request.lat, request.lng),
        infoWindow: InfoWindow(
          title: '${request.bloodGroup} Request (${request.units} units)',
          snippet: 'From: ${request.requesterName}',
        ),
        // Use a custom icon color to make requests stand out.
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      );
    }).toSet();
  }
}
