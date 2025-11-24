class BloodBankModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final Map<String, int> inventory; // Blood type -> units available
  final String? email;
  final String? operatingHours;
  final bool? isOpen24x7;

  const BloodBankModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.inventory,
    this.email,
    this.operatingHours,
    this.isOpen24x7,
  });

  factory BloodBankModel.fromJson(Map<String, dynamic> json) {
    double lat = 0;
    double lng = 0;

    // Handle different location formats
    if (json['latitude'] != null && json['longitude'] != null) {
      lat = (json['latitude'] as num).toDouble();
      lng = (json['longitude'] as num).toDouble();
    } else if (json['lat'] != null && json['lng'] != null) {
      lat = (json['lat'] as num).toDouble();
      lng = (json['lng'] as num).toDouble();
    } else if (json['location'] != null) {
      final location = json['location'] as Map<String, dynamic>;
      if (location['coordinates'] != null &&
          location['coordinates'] is List &&
          (location['coordinates'] as List).length == 2) {
        final coords = (location['coordinates'] as List).cast<num>();
        lng = coords[0].toDouble();
        lat = coords[1].toDouble();
      }
    }

    // Parse inventory
    Map<String, int> inventory = {};
    if (json['inventory'] != null) {
      if (json['inventory'] is Map) {
        final inv = json['inventory'] as Map<String, dynamic>;
        inv.forEach((key, value) {
          inventory[key] = (value as num).toInt();
        });
      } else if (json['inventory'] is List) {
        // Handle array format: [{bloodType: 'A+', units: 10}, ...]
        final invList = json['inventory'] as List;
        for (var item in invList) {
          if (item is Map) {
            final bloodType = item['bloodType']?.toString() ?? 
                            item['bloodGroup']?.toString();
            final units = item['units'] ?? item['quantity'] ?? 0;
            if (bloodType != null) {
              inventory[bloodType] = (units as num).toInt();
            }
          }
        }
      }
    }

    return BloodBankModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['contact']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
      inventory: inventory,
      email: json['email']?.toString(),
      operatingHours: json['operatingHours']?.toString() ?? 
                     json['hours']?.toString(),
      isOpen24x7: json['isOpen24x7'] as bool? ?? 
                 json['open24x7'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'inventory': inventory,
      if (email != null) 'email': email,
      if (operatingHours != null) 'operatingHours': operatingHours,
      if (isOpen24x7 != null) 'isOpen24x7': isOpen24x7,
    };
  }

  /// Get total units available for a specific blood type
  int getUnitsForBloodType(String bloodType) {
    return inventory[bloodType] ?? 0;
  }

  /// Check if blood type is available
  bool hasBloodType(String bloodType) {
    return (inventory[bloodType] ?? 0) > 0;
  }

  /// Get list of available blood types
  List<String> get availableBloodTypes {
    return inventory.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if any blood type has low stock (< 5 units)
  bool get hasLowStock {
    return inventory.values.any((units) => units > 0 && units < 5);
  }

  /// Get blood types with low stock
  List<String> get lowStockBloodTypes {
    return inventory.entries
        .where((entry) => entry.value > 0 && entry.value < 5)
        .map((entry) => entry.key)
        .toList();
  }
}

/// Helper class for blood inventory item
class BloodInventoryItem {
  final String bloodType;
  final int units;
  final DateTime? lastUpdated;

  const BloodInventoryItem({
    required this.bloodType,
    required this.units,
    this.lastUpdated,
  });

  factory BloodInventoryItem.fromJson(Map<String, dynamic> json) {
    return BloodInventoryItem(
      bloodType: json['bloodType']?.toString() ?? 
                json['bloodGroup']?.toString() ?? '',
      units: json['units'] != null
          ? (json['units'] as num).toInt()
          : json['quantity'] != null
              ? (json['quantity'] as num).toInt()
              : 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodType': bloodType,
      'units': units,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
    };
  }
}
