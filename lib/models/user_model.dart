class User {
  final String? id;
  final String? fullName; // Generic name (User/Requester) or Hospital Name / Blood Bank Name
  final String? email;
  final String? phone;
  final String? location;
  final int? age;
  final String? gender;
  final String? bloodGroup;
  final bool? isEmergency;
  final String? userType; // 'donor', 'requester', 'hospital', 'blood_bank', 'admin'
  final DateTime? lastDonationDate;
  final bool isAvailable;
  final int totalDonations;

  // Hospital / Blood Bank specific fields
  final String? hospital; // Often redundant with fullName if userType is hospital
  final String? hospitalLocation;
  final String? hospitalPhone;
  final String? registrationId;
  final String? contactPerson;
  final String? hospitalType; // government, private, etc.
  final bool? hasBloodBank;
  final bool? hasEmergency;
  final bool? isVerified;

  User({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.location,
    this.age,
    this.gender,
    this.bloodGroup,
    this.isEmergency,
    this.userType,
    this.lastDonationDate,
    this.isAvailable = true,
    this.totalDonations = 0,
    this.hospital,
    this.hospitalLocation,
    this.hospitalPhone,
    this.registrationId,
    this.contactPerson,
    this.hospitalType,
    this.hasBloodBank,
    this.hasEmergency,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'] ?? json['hospitalName'] ?? json['bloodBankName'] ?? json['name'],
      email: json['email'],
      phone: json['phone'] ?? json['phoneNumber'],
      location: json['location'] ?? json['address'] ?? json['fullAddress'],
      age: json['age'],
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      isEmergency: json['isEmergency'],
      userType: json['userType'],
      lastDonationDate: json['lastDonationDate'] != null ? DateTime.parse(json['lastDonationDate']) : null,
      isAvailable: json['isAvailable'] ?? true,
      totalDonations: json['totalDonations'] ?? 0,
      
      // Mapping for Hospital/BloodBank
      hospital: json['hospitalName'] ?? json['hospital'], 
      hospitalLocation: json['hospitalLocation'] ?? (json['city'] != null ? '${json['address']}, ${json['city']}' : null),
      hospitalPhone: json['hospitalPhone'] ?? json['phoneNumber'],
      registrationId: json['hospitalRegistrationId'] ?? json['licenseNumber'] ?? json['registrationId'],
      contactPerson: json['contactPerson'],
      hospitalType: json['hospitalType'] ?? json['category'],
      hasBloodBank: json['bloodBankFacility'],
      hasEmergency: json['emergencyService24x7'],
      isVerified: json['isVerified'],
    );
  }

  bool get isEligible {
    if (lastDonationDate == null) return true;
    final nextEligibleDate = lastDonationDate!.add(const Duration(days: 90));
    return DateTime.now().isAfter(nextEligibleDate);
  }
}
