import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jeevandhara/screens/requester/requester_blood_bank_screen.dart';

class BloodBankMapScreen extends StatefulWidget {
  final List<BloodBank> bloodBanks;

  const BloodBankMapScreen({super.key, required this.bloodBanks});

  @override
  State<BloodBankMapScreen> createState() => _BloodBankMapScreenState();
}

class _BloodBankMapScreenState extends State<BloodBankMapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  static const LatLng _center = LatLng(20.5937, 78.9629); // Default center (India)
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return;
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
    
    // Move camera to user's location if we haven't focused on markers yet
    if (widget.bloodBanks.isEmpty && _currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  void _createMarkers() {
    for (var bank in widget.bloodBanks) {
      // Only add markers for valid coordinates
      if (bank.latitude != 0.0 || bank.longitude != 0.0) {
        _markers.add(
          Marker(
            markerId: MarkerId(bank.id),
            position: LatLng(bank.latitude, bank.longitude),
            infoWindow: InfoWindow(
              title: bank.name,
              snippet: bank.location,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Blood Banks'),
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              await _getCurrentLocation();
              if (_currentPosition != null) {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      zoom: 15.0,
                    ),
                  ),
                );
              } else {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location not available')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          // If we have markers, try to fit them in bounds
          if (_markers.isNotEmpty) {
            _fitBounds();
          } else if (_currentPosition != null) {
             mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15.0,
                  ),
                ),
              );
          }
        },
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 5.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // We use our own button in AppBar or rely on Google's UI if we enable this
        zoomControlsEnabled: true,
      ),
    );
  }

  void _fitBounds() {
    if (_markers.isEmpty) return;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (var marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }
    
    // Include current position in bounds if available
    if (_currentPosition != null) {
      if (_currentPosition!.latitude < minLat) minLat = _currentPosition!.latitude;
      if (_currentPosition!.latitude > maxLat) maxLat = _currentPosition!.latitude;
      if (_currentPosition!.longitude < minLng) minLng = _currentPosition!.longitude;
      if (_currentPosition!.longitude > maxLng) maxLng = _currentPosition!.longitude;
    }

    if (minLat > maxLat) return; // Should not happen if markers exist

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
