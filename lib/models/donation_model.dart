/// Model representing a blood donation record
class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String bloodType;
  final String facilityId;
  final String facilityName;
  final int units;
  final DateTime donationDate;
  final String status; // 'completed', 'pending', 'cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.bloodType,
    required this.facilityId,
    required this.facilityName,
    required this.units,
    required this.donationDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['_id'] ?? json['id'] ?? '',
      donorId: json['donorId'] ?? json['donor_id'] ?? '',
      donorName: json['donorName'] ?? json['donor_name'] ?? '',
      bloodType: json['bloodType'] ?? json['blood_type'] ?? '',
      facilityId: json['facilityId'] ?? json['facility_id'] ?? '',
      facilityName: json['facilityName'] ?? json['facility_name'] ?? '',
      units: json['units'] ?? 1,
      donationDate: json['donationDate'] != null
          ? DateTime.parse(json['donationDate'])
          : json['donation_date'] != null
              ? DateTime.parse(json['donation_date'])
              : DateTime.now(),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'bloodType': bloodType,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'units': units,
      'donationDate': donationDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  DonationModel copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? bloodType,
    String? facilityId,
    String? facilityName,
    int? units,
    DateTime? donationDate,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      bloodType: bloodType ?? this.bloodType,
      facilityId: facilityId ?? this.facilityId,
      facilityName: facilityName ?? this.facilityName,
      units: units ?? this.units,
      donationDate: donationDate ?? this.donationDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
