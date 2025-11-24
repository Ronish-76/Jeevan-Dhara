import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/blood_request_model.dart';
import '../models/location_model.dart';
// FIX 1: Import the DonorModel so the ApiService knows what it is.
import '../models/donor_model.dart';

class ApiService {
  ApiService._();
  static final instance = ApiService._();

  // Using ADB reverse port forwarding
  static const _baseUrl = 'https://jeevan-dhara-s7wo.onrender.com/api';

  Future<List<LocationModel>> fetchNearbyFacilities({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    final uri = Uri.parse('$_baseUrl/map/nearby').replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radiusKm.toString(),
    });

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final facilities = (data['data'] as List)
          .map((json) => LocationModel.fromJson(json))
          .toList();
      return facilities;
    } else {
      throw Exception('Failed to load facilities: ${response.body}');
    }
  }

  Future<List<BloodRequestModel>> fetchActiveRequests() async {
    // This would typically fetch from your real-time DB or a dedicated endpoint
    // For now, we'll assume an endpoint on your Node.js server
    final uri = Uri.parse('$_baseUrl/requests/active');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['data'] as List)
          .map((json) => BloodRequestModel.fromJson(json))
          .toList();
    } else {
      return []; // Return empty list on failure
    }
  }

  Future<BloodRequestModel> createBloodRequest({
    required String requesterRole,
    required String requesterName,
    required String requesterContact,
    required String bloodGroup,
    required int units,
    required double lat,
    required double lng,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/requests');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'requesterRole': requesterRole,
        'requesterName': requesterName,
        'requesterContact': requesterContact,
        'bloodGroup': bloodGroup,
        'units': units,
        'location': {
          'type': 'Point',
          'coordinates': [lng, lat],
        },
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return BloodRequestModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to create request: ${response.body}');
    }
  }

  Future<BloodRequestModel> respondToRequest({
    required String requestId,
    required String responderRole,
    required String responderName,
    String? responderContact,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/requests/$requestId/respond');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'responderRole': responderRole,
        'responderName': responderName,
        'responderContact': responderContact,
        'notes': notes,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return BloodRequestModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to respond to request: ${response.body}');
    }
  }

  // FIX 2: Add the new getNearbyDonors method to the class.
  /// Fetches a list of nearby donors from the backend API.
  ///
  /// Can be filtered by location (lat/lng) and blood type.
  Future<List<DonorModel>> getNearbyDonors({
    double? latitude,
    double? longitude,
    String? bloodType,
  }) async {
    // 1. Construct the query parameters for the API request.
    final Map<String, String> queryParams = {
      if (latitude != null) 'lat': latitude.toString(),
      if (longitude != null) 'lng': longitude.toString(),
      if (bloodType != null) 'bloodType': bloodType,
      'isAvailable': 'true', // Usually, you only want to find available donors.
    };

    // 2. Create the full URI with the query parameters.
    // This assumes your backend has an endpoint like '/donors/nearby'.
    final uri = Uri.parse('$_baseUrl/donors/nearby').replace(queryParameters: queryParams);

    try {
      // 3. Make the HTTP GET request.
      final response = await http.get(uri);

      // 4. Check if the request was successful (HTTP 200 OK).
      if (response.statusCode == 200) {
        // 5. Decode the JSON response body.
        // Assuming the backend returns a structure like { "data": [...] }
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> jsonList = data['data'];

        // 6. Map the list of JSON objects to a list of DonorModel objects.
        return jsonList.map((json) => DonorModel.fromJson(json)).toList();
      } else {
        // If the server returns an error, throw an exception.
        throw Exception('Failed to load donors: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      // Handle network errors or other exceptions.
      print('Error in getNearbyDonors: $e');
      throw Exception('Failed to connect to the server.');
    }
  }
}
