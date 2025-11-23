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
    // Map 'unitsRequired' from HospitalBloodRequest to 'units'
    // Map 'notes' from HospitalBloodRequest to 'additionalDetails'
    
    return BloodRequest(
      id: json['_id'] ?? '',
      patientName: json['patientName'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      hospitalName: json['hospitalName'] ?? (json['hospital'] is Map ? json['hospital']['hospitalName'] : ''),
      location: json['location'] ?? (json['hospital'] is Map ? json['hospital']['address'] : ''),
      contactNumber: json['contactNumber'] ?? (json['hospital'] is Map ? json['hospital']['phoneNumber'] : ''),
      additionalDetails: json['additionalDetails'] ?? json['notes'],
      units: json['units'] ?? json['unitsRequired'] ?? 1,
      notifyViaEmergency: json['notifyViaEmergency'] ?? (json['urgency'] == 'critical' || json['urgency'] == 'high'),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      requesterName: json['requester'] != null && json['requester'] is Map 
          ? json['requester']['fullName'] 
          : (json['hospital'] is Map ? json['hospital']['hospitalName'] : null),
      donorId: json['donor'] is String ? json['donor'] : (json['donor'] != null && json['donor'] is Map ? json['donor']['_id'] : null),
    );
  }
}
