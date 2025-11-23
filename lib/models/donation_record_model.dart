
class DonationRecordModel {
  // FIX 5: The missing fields are now defined.
  final String id;
  final String donorId;
  final DateTime donationDate;
  final String bloodType;
  final int units;
  final String? location;
  final String? notes;

  const DonationRecordModel({
    required this.id,
    required this.donorId,
    required this.donationDate,
    required this.bloodType,
    required this.units,
    this.location,
    this.notes,
  });

  factory DonationRecordModel.fromJson(Map<String, dynamic> json) {
    return DonationRecordModel(
      // The logic here was good, it just needed the class to have the fields.
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? '',
      donationDate: json['donationDate'] != null
          ? DateTime.parse(json['donationDate'].toString())
          : DateTime.now(),
      bloodType: json['bloodType']?.toString() ?? '',
      units: json['units'] != null ? (json['units'] as num).toInt() : 1,
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    // This now works because the fields exist.
    return {
      'id': id,
      'donorId': donorId,
      'donationDate': donationDate.toIso8601String(),
      'bloodType': bloodType,
      'units': units,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
    };
  }
}
