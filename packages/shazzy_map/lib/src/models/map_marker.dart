import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ShazzyMarkerType {
  hospital,
  bloodBank,
  donor,
  request,
  unknown,
}

class ShazzyMarker {
  final String id;
  final LatLng position;
  final String title;
  final String? snippet;
  final BitmapDescriptor? icon;
  final Function()? onTap;
  final ShazzyMarkerType type;
  final Map<String, dynamic>? data;

  const ShazzyMarker({
    required this.id,
    required this.position,
    required this.title,
    this.snippet,
    this.icon,
    this.onTap,
    this.type = ShazzyMarkerType.unknown,
    this.data,
  });
}
