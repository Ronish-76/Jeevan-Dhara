class User {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? location;
  final int? age;
  final String? gender;
  final String? hospital;
  final String? hospitalLocation;
  final String? hospitalPhone;
  final String? bloodGroup;
  final bool? isEmergency;
  final String? userType;
  final DateTime? lastDonationDate;
  final bool isAvailable;
  final int totalDonations;

  User({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.location,
    this.age,
    this.gender,
    this.hospital,
    this.hospitalLocation,
    this.hospitalPhone,
    this.bloodGroup,
    this.isEmergency,
    this.userType,
    this.lastDonationDate,
    this.isAvailable = true,
    this.totalDonations = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      age: json['age'],
      gender: json['gender'],
      hospital: json['hospitalName'] ?? json['hospital'],
      hospitalLocation: json['hospitalLocation'],
      hospitalPhone: json['hospitalPhone'],
      bloodGroup: json['bloodGroup'],
      isEmergency: json['isEmergency'],
      userType: json['userType'],
      lastDonationDate: json['lastDonationDate'] != null ? DateTime.parse(json['lastDonationDate']) : null,
      isAvailable: json['isAvailable'] ?? true,
      totalDonations: json['totalDonations'] ?? 0,
    );
  }

  bool get isEligible {
    if (lastDonationDate == null) return true;
    final nextEligibleDate = lastDonationDate!.add(const Duration(days: 90));
    return DateTime.now().isAfter(nextEligibleDate);
  }
}
