class Donor {
  final String name;
  final String bloodGroup;
  final String location;
  final bool isAvailable;
  final int lastDonationMonthsAgo;
  final int totalDonations;

  Donor({
    required this.name,
    required this.bloodGroup,
    required this.location,
    required this.isAvailable,
    required this.lastDonationMonthsAgo,
    required this.totalDonations,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    return Donor(
      name: json['name'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      location: json['location'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
      lastDonationMonthsAgo: json['lastDonationMonthsAgo'] ?? 0,
      totalDonations: json['totalDonations'] ?? 0,
    );
  }
}
