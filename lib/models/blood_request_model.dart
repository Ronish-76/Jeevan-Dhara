class BloodRequest {
  final String id;
  final String patientName;
  final String patientPhone;
  final String bloodGroup;
  final String hospitalName;
  final String location;
  final String contactNumber;
  final String? additionalDetails;
  final int units;
  final bool notifyViaEmergency;
  final String status;
  final DateTime createdAt;
  final String? requesterName;
  final String? donorId;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.bloodGroup,
    required this.hospitalName,
    required this.location,
    required this.contactNumber,
    this.additionalDetails,
    required this.units,
    required this.notifyViaEmergency,
    required this.status,
    required this.createdAt,
    this.requesterName,
    this.donorId,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['_id'] ?? '',
      patientName: json['patientName'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      location: json['location'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      additionalDetails: json['additionalDetails'],
      units: json['units'] ?? 1,
      notifyViaEmergency: json['notifyViaEmergency'] ?? false,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      requesterName: json['requester'] != null && json['requester'] is Map 
          ? json['requester']['fullName'] 
          : null,
      donorId: json['donor'] is String ? json['donor'] : (json['donor'] != null && json['donor'] is Map ? json['donor']['_id'] : null),
    );
  }
}
