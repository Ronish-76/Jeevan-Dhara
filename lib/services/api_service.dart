import 'dart:convert';

import 'package:http/http.dart' as http;
<<<<<<< HEAD
import 'package:jeevandhara/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> get _headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
        headers: await _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
        headers: await _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
        headers: await _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
        headers: await _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  Future<List<dynamic>> getDonors() async {
    final response = await get('donors');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> searchDonors(String query) async {
    final response = await get('donors/search?search=$query');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getBloodBanks() async {
    final response = await get('blood-banks');
    return response as List<dynamic>;
  }
  
  Future<dynamic> getBloodBankProfile(String id) async {
    return await get('blood-banks/$id');
  }

  Future<dynamic> registerBloodBank(Map<String, dynamic> data) async {
    return await post('blood-banks/register', data);
  }

  Future<dynamic> registerHospital(Map<String, dynamic> data) async {
    return await post('hospitals/register', data);
  }
  
  Future<List<dynamic>> searchHospitals(String query) async {
    final response = await get('hospitals?search=$query');
    return response as List<dynamic>;
  }

  Future<dynamic> recordDonation(String bloodBankId, Map<String, dynamic> data) async {
    return await post('blood-banks/$bloodBankId/donations', data);
  }

  Future<List<dynamic>> getDonations(String bloodBankId) async {
    final response = await get('blood-banks/$bloodBankId/donations');
    return response as List<dynamic>;
  }
  
  Future<dynamic> recordDistribution(String bloodBankId, Map<String, dynamic> data) async {
    return await post('blood-banks/$bloodBankId/distributions', data);
  }
  
  Future<List<dynamic>> getDistributions(String bloodBankId) async {
    final response = await get('blood-banks/$bloodBankId/distributions');
    return response as List<dynamic>;
  }
  
  Future<List<dynamic>> getBloodBankRequests(String bloodBankId) async {
    final response = await get('blood-banks/$bloodBankId/requests');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getRequesterBloodRequests(String userId) async {
    final response = await get('blood-requests/requester/$userId');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getAllBloodRequests() async {
    final response = await get('blood-requests');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getDonorDonationHistory(String donorId) async {
    final response = await get('blood-requests/donor/$donorId/history');
    return response as List<dynamic>;
  }

  Future<dynamic> createBloodRequest(Map<String, dynamic> data) async {
    return await post('blood-requests', data);
  }

  Future<dynamic> cancelBloodRequest(String requestId) async {
    return await put('blood-requests/$requestId/cancel', {});
  }

  Future<dynamic> acceptBloodRequest(String requestId, String donorId) async {
    return await post('blood-requests/accept', {
      'requestId': requestId,
      'donorId': donorId,
    });
  }

  Future<dynamic> fulfillBloodRequest(String requestId, String donorId) async {
    return await post('blood-requests/fulfill', {
      'requestId': requestId,
      'donorId': donorId,
    });
  }

  // Hospital Endpoints
  Future<List<dynamic>> getHospitalBloodRequests(String hospitalId) async {
    final response = await get('hospitals/$hospitalId/blood-requests');
    return response as List<dynamic>;
  }

  Future<dynamic> createHospitalBloodRequest(String hospitalId, Map<String, dynamic> data) async {
    return await post('hospitals/$hospitalId/blood-requests', data);
  }

  Future<List<dynamic>> getHospitalStock(String hospitalId) async {
    final response = await get('hospitals/$hospitalId/blood-stock');
    return response as List<dynamic>;
  }

  Future<dynamic> addHospitalStock(String hospitalId, Map<String, dynamic> data) async {
    return await post('hospitals/$hospitalId/blood-stock', data);
  }

  Future<dynamic> updateHospitalStock(String stockId, Map<String, dynamic> data) async {
    return await put('hospitals/blood-stock/$stockId', data);
  }

  Future<dynamic> deleteHospitalStock(String stockId) async {
    return await delete('hospitals/blood-stock/$stockId');
=======

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
>>>>>>> map-feature
  }
}
