// lib/models/donor_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// RECOMMENDATION: Use a consistent name, e.g., 'DonorModel'.
class DonorModel {
  // RECOMMENDATION #1: Add a unique ID.
  final String id;
  final String name;
  final String bloodGroup;
  final bool isAvailable;

  // RECOMMENDATION #2: Use specific fields for location data.
  final String? locationName; // For display, e.g., "Bir Hospital, Kathmandu"
  final GeoPoint? coordinates; // For geospatial queries

  // These are good fields for donor history.
  final int lastDonationMonthsAgo;
  final int totalDonations;

  // Added for finding nearby donors
  final double? distanceKm;

  const DonorModel({
    required this.id, // Added to constructor
    required this.name,
    required this.bloodGroup,
    required this.isAvailable,
    this.locationName,
    this.coordinates,
    required this.lastDonationMonthsAgo,
    required this.totalDonations,
    this.distanceKm,
  });

  // RECOMMENDATION #3: A dedicated constructor for Firestore data.
  factory DonorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DonorModel(
      id: doc.id, // Use the document's ID as the unique ID.
      name: data['name'] ?? '',
      bloodGroup: data['bloodGroup'] ?? 'N/A',
      isAvailable: data['isAvailable'] ?? false,
      locationName: data['locationName'],
      coordinates: data['coordinates'] as GeoPoint?,
      lastDonationMonthsAgo: (data['lastDonationMonthsAgo'] as num?)?.toInt() ?? 0,
      totalDonations: (data['totalDonations'] as num?)?.toInt() ?? 0,
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }

  // Your fromJson method is good but can be updated for the new structure.
  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bloodGroup: json['bloodGroup'] ?? json['bloodType'] ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      locationName: json['location'], // The old 'location' string now maps to 'locationName'
      coordinates: null, // fromJson doesn't handle GeoPoint easily, so this can be null
      lastDonationMonthsAgo: (json['lastDonationMonthsAgo'] as num?)?.toInt() ?? 0,
      totalDonations: (json['totalDonations'] as num?)?.toInt() ?? 0,
    );
  }

  // A toJson method is useful for writing data back to Firestore.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bloodGroup': bloodGroup,
      'isAvailable': isAvailable,
      'locationName': locationName,
      'coordinates': coordinates,
      'lastDonationMonthsAgo': lastDonationMonthsAgo,
      'totalDonations': totalDonations,
    };
  }
}
