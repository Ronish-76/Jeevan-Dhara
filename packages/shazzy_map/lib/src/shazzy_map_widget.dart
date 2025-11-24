import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shazzy_map/src/models/map_marker.dart';
import 'package:shazzy_map/src/shazzy_controller.dart';

class ShazzyMap extends StatefulWidget {
  final List<ShazzyMarker> markers;
  final ShazzyController? controller;
  final LatLng initialPosition;
  final bool showUserLocation;
  final Function(LatLng)? onMapTap;
  final double initialZoom;
  final Set<Polyline> polylines;

  const ShazzyMap({
    super.key,
    this.markers = const [],
    this.controller,
    this.initialPosition = const LatLng(27.7172, 85.3240), // Kathmandu default
    this.showUserLocation = true,
    this.onMapTap,
    this.initialZoom = 13,
    this.polylines = const {},
  });

  @override
  State<ShazzyMap> createState() => _ShazzyMapState();
}

class _ShazzyMapState extends State<ShazzyMap> {
  final Completer<GoogleMapController> _controller = Completer();
  
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    if (!widget.showUserLocation) return;
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      markers: widget.markers.map((m) {
        return Marker(
          markerId: MarkerId(m.id),
          position: m.position,
          infoWindow: InfoWindow(
            title: m.title,
            snippet: m.snippet,
          ),
          icon: m.icon ?? BitmapDescriptor.defaultMarker,
          onTap: m.onTap,
        );
      }).toSet(),
      polylines: widget.polylines,
      myLocationEnabled: widget.showUserLocation,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: true,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        widget.controller?.setController(controller);
      },
      onTap: widget.onMapTap,
    );
  }
}
