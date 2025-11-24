enum UserRole { patient, donor, hospital, bloodBank }

enum LocationType { hospital, bloodBank, donor }

extension LocationTypeExtension on LocationType {
  String get name {
    switch (this) {
      case LocationType.hospital:
        return 'hospital';
      case LocationType.bloodBank:
        return 'bloodBank';
      case LocationType.donor:
        return 'donor';
    }
  }
}

class LocationModel {
  final String id;
  final String name;
  final String displayAddress;
  final double latitude;
  final double longitude;
  final LocationType type;
  final Map<String, int>? inventory;
  final List<String>? bloodTypesAvailable;
  final List<String>? services;
  final Map<String, dynamic>? availability;
  final String? contactNumber;
  final String? email;
  final double? distance; // Distance in km from user location
  final bool? isAvailable; // For donors

  LocationModel({
    required this.id,
    required this.name,
    required this.displayAddress,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.inventory,
    this.bloodTypesAvailable,
    this.services,
    this.availability,
    this.contactNumber,
    this.email,
    this.distance,
    this.isAvailable,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    // Handle coordinates from geo or coordinates field (backend may return either)
    List<dynamic>? coords;
    // First check geo field (canonical)
    if (json['geo'] != null && json['geo'] is Map) {
      final geo = json['geo'] as Map<String, dynamic>;
      if (geo['coordinates'] != null && geo['coordinates'] is List) {
        coords = geo['coordinates'] as List<dynamic>;
      }
    }
    // Fallback to coordinates field (legacy)
    if (coords == null && json['coordinates'] != null) {
      if (json['coordinates'] is List) {
        coords = json['coordinates'] as List<dynamic>;
      } else if (json['coordinates'] is Map &&
          json['coordinates']['coordinates'] != null) {
        coords = json['coordinates']['coordinates'] as List<dynamic>;
      }
    }

    // Handle type: 'blood_bank' from backend vs 'bloodBank' in Flutter
    String typeStr = json['type'] as String? ?? 'hospital';
    LocationType locationType;
    if (typeStr == 'blood_bank') {
      locationType = LocationType.bloodBank;
    } else {
      locationType = LocationType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
        orElse: () => LocationType.hospital,
      );
    }

    // Build display address from address object or string
    String displayAddr = '';
    if (json['displayAddress'] != null) {
      displayAddr = json['displayAddress'] as String;
    } else if (json['address'] != null) {
      if (json['address'] is Map) {
        final addr = json['address'] as Map<String, dynamic>;
        final parts = <String>[];
        if (addr['street'] != null) parts.add(addr['street'] as String);
        if (addr['city'] != null) parts.add(addr['city'] as String);
        if (addr['district'] != null) parts.add(addr['district'] as String);
        displayAddr = parts.join(', ');
      } else {
        displayAddr = json['address'] as String;
      }
    }

    // Convert inventory Map to Map<String, int>
    Map<String, int>? inv;
    if (json['inventory'] != null) {
      if (json['inventory'] is Map) {
        inv = {};
        (json['inventory'] as Map).forEach((key, value) {
          if (value is num) {
            inv![key.toString()] = value.toInt();
          }
        });
      }
    }

    return LocationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      displayAddress: displayAddr,
      latitude: coords != null && coords.length >= 2
          ? (coords[1] as num).toDouble()
          : 0.0,
      longitude: coords != null && coords.length >= 2
          ? (coords[0] as num).toDouble()
          : 0.0,
      type: locationType,
      inventory: inv,
      bloodTypesAvailable: json['bloodTypesAvailable'] != null
          ? List<String>.from(json['bloodTypesAvailable'] as List)
          : null,
      services: json['services'] != null
          ? List<String>.from(json['services'] as List)
          : null,
      availability: json['availability'] != null
          ? Map<String, dynamic>.from(json['availability'] as Map)
          : null,
      contactNumber: json['contactNumber'] as String?,
      email: json['email'] as String?,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      isAvailable: json['isAvailable'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'displayAddress': displayAddress,
      'coordinates': [longitude, latitude],
      'type': type == LocationType.bloodBank ? 'blood_bank' : type.name,
      'inventory': inventory,
      'bloodTypesAvailable': bloodTypesAvailable,
      'services': services,
      'availability': availability,
      'contactNumber': contactNumber,
      'email': email,
      'distance': distance,
      'isAvailable': isAvailable,
    };
  }
}
