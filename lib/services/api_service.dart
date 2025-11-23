import 'dart:convert';

import 'package:http/http.dart' as http;
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
  }
}
