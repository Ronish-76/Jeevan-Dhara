import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jeevandhara/models/location_model.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

/// Helper class for creating custom marker icons
class CustomMarkerIcon {
  /// Get custom marker icon based on location type
  /// Note: Using default Google Maps markers with different colors
  static Future<BitmapDescriptor> getLocationIcon(
    LocationType type, {
    bool isUrgent = false,
    String? label,
  }) async {
    double hue;

    switch (type) {
      case LocationType.hospital:
        hue = isUrgent ? BitmapDescriptor.hueRed : BitmapDescriptor.hueRose;
        break;
      case LocationType.bloodBank:
        hue = isUrgent ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueBlue;
        break;
      case LocationType.donor:
        hue = BitmapDescriptor.hueGreen;
        break;
    }

    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  /// Get custom marker icon for blood requests
  /// Note: Using default Google Maps markers with different colors
  static Future<BitmapDescriptor> getRequestIcon({
    required String urgency,
    String? label,
  }) async {
    double hue;

    switch (urgency) {
      case 'critical':
        hue = BitmapDescriptor.hueRed;
        break;
      case 'high':
        hue = BitmapDescriptor.hueOrange;
        break;
      case 'medium':
        hue = BitmapDescriptor.hueYellow;
        break;
      default:
        hue = BitmapDescriptor.hueBlue;
        break;
    }

    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }


}
