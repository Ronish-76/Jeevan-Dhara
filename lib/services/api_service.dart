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

  Future<List<dynamic>> getRequesterBloodRequests(String userId) async {
    final response = await get('blood-requests/requester/$userId');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getAllBloodRequests() async {
    final response = await get('blood-requests');
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
}
