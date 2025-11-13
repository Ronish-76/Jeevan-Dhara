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
}
