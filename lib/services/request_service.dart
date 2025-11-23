import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/blood_request_model.dart';

/// Service for handling blood request-related API calls
class RequestService {
  RequestService._();

  static final RequestService instance = RequestService._();

  factory RequestService() => instance;

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

  /// Get all active blood requests
  Future<List<BloodRequestModel>> getActiveRequests() async {
    final uri = _uri('/requests/active');

    final response = await _safeRequest(
      () => _client.get(uri),
    );

    final List<dynamic> data =
        response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => BloodRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Create a new blood request
  Future<BloodRequestModel> createRequest({
    required String requesterRole,
    required String requesterName,
    required String requesterContact,
    required String bloodGroup,
    required int units,
    required double lat,
    required double lng,
    String? notes,
    String? address,
    String? urgency,
  }) async {
    final uri = _uri('/requests/create');
    final payload = {
      'requesterRole': requesterRole,
      'requesterName': requesterName,
      'requesterContact': requesterContact,
      'bloodGroup': bloodGroup,
      'units': units,
      'lat': lat,
      'lng': lng,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (address != null && address.isNotEmpty) 'address': address,
      if (urgency != null && urgency.isNotEmpty) 'urgency': urgency,
    };

    final response = await _safeRequest(
      () => _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ),
    );

    final requestData = response['data'] ?? response['request'];
    if (requestData == null) {
      throw Exception('Invalid response: missing request data');
    }

    return BloodRequestModel.fromJson(requestData as Map<String, dynamic>);
  }

  /// Respond to a blood request
  Future<BloodRequestModel> respondToRequest({
    required String requestId,
    required String responderRole,
    required String responderName,
    String? responderContact,
    String? notes,
  }) async {
    final uri = _uri('/requests/respond');
    final payload = {
      'requestId': requestId,
      'responderRole': responderRole,
      'responderName': responderName,
      if (responderContact != null && responderContact.isNotEmpty)
        'responderContact': responderContact,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _safeRequest(
      () => _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ),
    );

    final requestData = response['data'] ?? response['request'];
    if (requestData == null) {
      throw Exception('Invalid response: missing request data');
    }

    return BloodRequestModel.fromJson(requestData as Map<String, dynamic>);
  }

  /// Get a specific blood request by ID
  Future<BloodRequestModel> getRequestById(String requestId) async {
    final uri = _uri('/requests/$requestId');

    final response = await _safeRequest(
      () => _client.get(uri),
    );

    final requestData = response['data'] ?? response['request'];
    if (requestData == null) {
      throw Exception('Invalid response: missing request data');
    }

    return BloodRequestModel.fromJson(requestData as Map<String, dynamic>);
  }

  /// Get requests by status
  Future<List<BloodRequestModel>> getRequestsByStatus(String status) async {
    final uri = _uri('/requests', {'status': status});

    final response = await _safeRequest(
      () => _client.get(uri),
    );

    final List<dynamic> data =
        response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => BloodRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Get requests by blood type
  Future<List<BloodRequestModel>> getRequestsByBloodType(
    String bloodType,
  ) async {
    final uri = _uri('/requests', {'bloodType': bloodType});

    final response = await _safeRequest(
      () => _client.get(uri),
    );

    final List<dynamic> data =
        response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => BloodRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Update request status
  Future<BloodRequestModel> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    final uri = _uri('/requests/$requestId/status');
    final payload = {'status': status};

    final response = await _safeRequest(
      () => _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ),
    );

    final requestData = response['data'] ?? response['request'];
    if (requestData == null) {
      throw Exception('Invalid response: missing request data');
    }

    return BloodRequestModel.fromJson(requestData as Map<String, dynamic>);
  }

  /// Cancel a blood request
  Future<void> cancelRequest(String requestId) async {
    final uri = _uri('/requests/$requestId');

    await _safeRequest(
      () => _client.delete(uri),
    );
  }

  Future<Map<String, dynamic>> _safeRequest(
    Future<http.Response> Function() operation,
  ) async {
    try {
      final http.Response httpResponse = await operation().timeout(
        AppConfig.networkTimeout,
      );

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
