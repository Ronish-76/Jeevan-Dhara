import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
// FIX 1: Import the models from their own files
import '../models/donor_model.dart';
import '../models/donation_record_model.dart';

/// Service for handling donor-related API calls
class DonorService {
  DonorService._();
  static final DonorService instance = DonorService._();
  factory DonorService() => instance;

  final http.Client _client = http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api$normalizedPath');
    if (query == null || query.isEmpty) return uri;
    final qp = <String, String>{};
    query.forEach((key, value) {
      if (value == null) return;
      qp[key] = value.toString();
    });
    return uri.replace(queryParameters: qp);
  }

  // FIX 2: Use DonorModel instead of Donor
  Future<DonorModel> getDonorProfile(String donorId) async {
    final uri = _uri('/donors/$donorId');
    final response = await _safeRequest(() => _client.get(uri));
    final donorData = response['data'] ?? response['donor'];
    if (donorData == null) {
      throw Exception('Invalid response: missing donor data');
    }
    return DonorModel.fromJson(donorData as Map<String, dynamic>);
  }

  Future<DonorModel> updateAvailability({
    required String donorId,
    required bool isAvailable,
  }) async {
    final uri = _uri('/donors/$donorId/availability');
    final payload = {'isAvailable': isAvailable};
    final response = await _safeRequest(() => _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ));
    final donorData = response['data'] ?? response['donor'];
    if (donorData == null) {
      throw Exception('Invalid response: missing donor data');
    }
    return DonorModel.fromJson(donorData as Map<String, dynamic>);
  }

  // FIX 3: Use DonationRecordModel instead of DonationRecord
  Future<List<DonationRecordModel>> getDonationHistory(String donorId) async {
    final uri = _uri('/donors/$donorId/donations');
    final response = await _safeRequest(() => _client.get(uri));
    final List<dynamic> data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => DonationRecordModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<DonorModel>> getNearbyDonors({
    required double latitude,
    required double longitude,
    required String bloodType,
    double radiusKm = 10,
  }) async {
    final uri = _uri('/donors/nearby', {
      'lat': latitude,
      'lng': longitude,
      'bloodType': bloodType,
      'radius': radiusKm,
    });
    final response = await _safeRequest(() => _client.get(uri));
    final List<dynamic> data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => DonorModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DonorModel> updateDonorProfile({
    required String donorId,
    required Map<String, dynamic> updates,
  }) async {
    final uri = _uri('/donors/$donorId');
    final response = await _safeRequest(() => _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    ));
    final donorData = response['data'] ?? response['donor'];
    if (donorData == null) {
      throw Exception('Invalid response: missing donor data');
    }
    return DonorModel.fromJson(donorData as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _safeRequest(
      Future<http.Response> Function() operation,
      ) async {
    // This helper method is well-written and needs no changes.
    try {
      final http.Response httpResponse =
      await operation().timeout(AppConfig.networkTimeout);
      final Map<String, dynamic> decoded =
      jsonDecode(httpResponse.body) as Map<String, dynamic>;
      final success =
          decoded['success'] == true || httpResponse.statusCode < 400;
      if (!success) {
        final message = decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Request failed with ${httpResponse.statusCode}';
        throw Exception(message);
      }
      return decoded;
    } on FormatException catch (error) {
      throw Exception('Invalid server response: ${error.message}');
    } on Exception {
      rethrow;
    }
  }
}
