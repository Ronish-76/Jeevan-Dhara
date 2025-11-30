class BloodRequest {
  final String id;
  final String patientName;
  final String patientPhone;
  final String bloodGroup;
  final String hospitalName;
  final String location;
  final double? latitude;
  final double? longitude;
  final String contactNumber;
  final String? additionalDetails;
  final int units;
  final bool notifyViaEmergency;
  final String status;
  final DateTime createdAt;
  final String? requesterName;
  final String? donorId;
  final String? donorName;
  final bool isHospitalRequest;
  final String? hospitalId;
  final String? requestedFrom;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.bloodGroup,
    required this.hospitalName,
    required this.location,
    this.latitude,
    this.longitude,
    required this.contactNumber,
    this.additionalDetails,
    required this.units,
    required this.notifyViaEmergency,
    required this.status,
    required this.createdAt,
    this.requesterName,
    this.donorId,
    this.donorName,
    this.isHospitalRequest = false,
    this.hospitalId,
    this.requestedFrom,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    // Handle latitude/longitude parsing safely
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }
    
    // Robust detection of hospital request
    bool isHospitalReq = json['requestType'] == 'Hospital' || 
                         json['requester'] == null || 
                         (json['hospital'] != null && json['hospital'] != '' && json['hospital'] != 'null');

    // Extract hospital ID if available
    String? extractedHospitalId;
    if (json['hospital'] is String) {
      extractedHospitalId = json['hospital'];
    } else if (json['hospital'] is Map) {
      extractedHospitalId = json['hospital']['_id'] ?? json['hospital']['id'];
    }

    return BloodRequest(
      id: json['_id'] ?? json['id'] ?? '',
      patientName: json['patientName'] ?? '',
      patientPhone: json['patientPhone'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      hospitalName: json['hospitalName'] ?? (json['hospital'] is Map ? json['hospital']['hospitalName'] : ''),
      location: json['location'] ?? (json['hospital'] is Map ? json['hospital']['address'] : ''),
      latitude: parseDouble(json['latitude'] ?? (json['hospital'] is Map ? json['hospital']['latitude'] : null)),
      longitude: parseDouble(json['longitude'] ?? (json['hospital'] is Map ? json['hospital']['longitude'] : null)),
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
      donorName: json['donor'] != null && json['donor'] is Map ? json['donor']['fullName'] : null,
      isHospitalRequest: isHospitalReq,
      hospitalId: extractedHospitalId,
      requestedFrom: json['requestedFrom'],
    );
  }
  
  // Helper to create a copy with updated fields
  BloodRequest copyWith({
    String? hospitalName,
    String? location,
    String? contactNumber,
    double? latitude,
    double? longitude,
    String? status,
    String? donorId,
    bool? isHospitalRequest,
  }) {
    return BloodRequest(
      id: id,
      patientName: patientName,
      patientPhone: patientPhone,
      bloodGroup: bloodGroup,
      hospitalName: hospitalName ?? this.hospitalName,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactNumber: contactNumber ?? this.contactNumber,
      additionalDetails: additionalDetails,
      units: units,
      notifyViaEmergency: notifyViaEmergency,
      status: status ?? this.status,
      createdAt: createdAt,
      requesterName: requesterName,
      donorId: donorId ?? this.donorId,
      donorName: donorName,
      isHospitalRequest: isHospitalRequest ?? this.isHospitalRequest,
      hospitalId: hospitalId,
      requestedFrom: requestedFrom,
    );
  }
}
