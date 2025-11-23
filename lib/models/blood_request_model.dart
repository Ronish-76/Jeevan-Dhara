import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a real-time blood request on the map.
class BloodRequestModel {

  final String id;
  final String requesterName;
  final String requesterContact; // Added
  final String bloodGroup;
  final int units;
  final double lat;
  final double lng;
  final String status; // e.g., 'active', 'pending', 'fulfilled'
  final String? notes;
  final String? responderName;
  final String? locationName; // Added
  final DateTime? createdAt; // Added
  final double? distanceKm; // Added
  final String? urgency;

  const BloodRequestModel({
    required this.id,
    required this.requesterName,
    required this.requesterContact, // Added
    required this.bloodGroup,
    required this.units,
    required this.lat,
    required this.lng,
    required this.status,
    this.notes,
    this.responderName,
    this.locationName,
    this.createdAt,
    this.distanceKm,
    this.urgency,
  });

  // Getters for compatibility
  String get bloodType => bloodGroup;

  factory BloodRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationData = data['location'] ?? data['position'];
    GeoPoint? location;
    if (locationData is GeoPoint) {
      location = locationData;
    } else if (locationData is Map && locationData.containsKey('geopoint')) {
      location = locationData['geopoint'] as GeoPoint?;
    }
    return BloodRequestModel(
      id: doc.id,
      requesterName: data['requesterName'] ?? '',
      requesterContact: data['requesterContact'] ?? '', // Added
      bloodGroup: data['bloodGroup'] ?? '',
      units: data['units'] as int? ?? 0,
      lat: location?.latitude ?? 0.0,
      lng: location?.longitude ?? 0.0,
      status: data['status'] ?? 'pending',
      notes: data['notes'] as String?,
      responderName: data['responderName'] as String?,
      locationName: data['locationName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      distanceKm: (data['distance'] as num?)?.toDouble(),
      urgency: data['urgency'] as String?,
    );
  }

  factory BloodRequestModel.fromJson(Map<String, dynamic> json) {
    final location = json['location']?['coordinates'] as List?;
    return BloodRequestModel(
      id: json['_id'] as String,
      requesterName: json['requesterName'] as String,
      requesterContact: json['requesterContact'] as String? ?? '', // Added
      bloodGroup: json['bloodGroup'] as String,
      units: json['units'] as int,
      lat: location?[1] as double? ?? 0.0, // Backend sends [lng, lat]
      lng: location?[0] as double? ?? 0.0,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      responderName: json['responderName'] as String?,
      locationName: json['locationName'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      distanceKm: (json['distance'] as num?)?.toDouble(),
      urgency: json['urgency'] as String?,
    );
  }
}
