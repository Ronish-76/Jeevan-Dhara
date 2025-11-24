import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import 'package:jeevandhara/models/location_model.dart';

class MapsHelper {
  /// Open Google Maps navigation to a location
  static Future<void> openGoogleMapsNavigation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude${label != null ? '&destination_place_id=$label' : ''}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Google Maps');
    }
  }

  /// Open Google Maps with a location
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch Google Maps');
    }
  }

  /// Calculate distance between two points (Haversine formula)
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        (dLat / 2).sin() * (dLat / 2).sin() +
        _degreesToRadians(lat1).cos() *
            _degreesToRadians(lat2).cos() *
            (dLon / 2).sin() *
            (dLon / 2).sin();

    final double c = 2 * (a.sqrt()).atan2((1 - a).sqrt());

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (3.141592653589793 / 180);
  }

  /// Format distance for display
  static String formatDistance(double? distanceKm) {
    if (distanceKm == null) return 'Unknown';
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Get custom marker icon based on location type
  /// Note: This is a placeholder - actual marker creation should use shazzy_map
  static String getMarkerColor(
    LocationType type, {
    bool isUrgent = false,
  }) {
    switch (type) {
      case LocationType.hospital:
        return isUrgent ? 'red' : 'red';
      case LocationType.bloodBank:
        return isUrgent ? 'red' : 'blue';
      case LocationType.donor:
        return 'green';
    }
  }
}

// Extension for sin, cos, sqrt, atan2
extension MathExtensions on double {
  double sin() => math.sin(this);
  double cos() => math.cos(this);
  double sqrt() => math.sqrt(this);
  double atan2(double other) => math.atan2(this, other);
}
