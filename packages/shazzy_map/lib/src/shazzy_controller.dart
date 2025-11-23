import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShazzyController {
  GoogleMapController? _mapController;

  void setController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> moveCamera(LatLng position, {double zoom = 15}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }
  
  Future<void> fitBounds(LatLngBounds bounds, {double padding = 50}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, padding),
    );
  }

  void dispose() {
    _mapController = null;
  }
}
