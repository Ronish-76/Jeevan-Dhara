class Donor {
  final String id;
  final String name;
  final String bloodGroup;
  final String location;
  final bool isAvailable;
  final int lastDonationMonthsAgo;
  final int totalDonations;
  final String? phone;
  final String? email;

  Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.location,
    required this.isAvailable,
    required this.lastDonationMonthsAgo,
    required this.totalDonations,
    this.phone,
    this.email,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      id: json['_id'] ?? '',
      name: json['fullName'] ?? 'Unknown', // Backend returns fullName
      bloodGroup: json['bloodGroup'] ?? '',
      location: json['location'] ?? '',
      isAvailable: json['isAvailable'] ?? true, // Assuming default true if not present
      lastDonationMonthsAgo: json['lastDonationMonthsAgo'] ?? 0, // Adjust if backend doesn't have this yet
      totalDonations: json['totalDonations'] ?? 0,
      phone: json['phone'],
      email: json['email'],
    );
  }
}
