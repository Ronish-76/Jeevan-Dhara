import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jeevandhara/models/location_model.dart';
import 'package:jeevandhara/models/blood_request_model.dart';

class MapService {
  // Using ADB reverse port forwarding: adb reverse tcp:5000 tcp:5000
  static const String _baseUrl = 'http://localhost:5000/api';
  // For iOS simulator use: 'http://127.0.0.1:5000/api'
  // For physical device, use your computer's IP address

  // Get nearby locations
  Future<List<LocationModel>> getNearbyLocations({
    required double latitude,
    required double longitude,
    required UserRole role,
    double radius = 10,
    String? bloodType,
    String? availability,
    int limit = 25,
  }) async {
    final uri = Uri.parse('$_baseUrl/locations/nearby').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'role': _roleToString(role),
        'radius': radius.toString(),
        'limit': limit.toString(),
        if (bloodType != null) 'bloodType': bloodType,
        if (availability != null) 'availability': availability,
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'] as List;
          return data.map((json) => LocationModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get blood bank inventory
  Future<Map<String, dynamic>> getBloodBankInventory(String bloodBankId) async {
    final uri = Uri.parse(
      '$_baseUrl/locations/bloodbanks/$bloodBankId/inventory',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return jsonData['data'] as Map<String, dynamic>;
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load inventory: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Create blood request from map
  Future<BloodRequestModel> createRequestFromMap({
    required String requesterId,
    required String requesterName,
    required String requesterPhone,
    required String bloodType,
    required int quantity,
    String urgency = 'medium',
    String? locationId,
    double? latitude,
    double? longitude,
    String? address,
    String? reason,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/blood-requests/create-from-map');

    final body = json.encode({
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhone': requesterPhone,
      'bloodType': bloodType,
      'quantity': quantity,
      'urgency': urgency,
      'locationId': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'reason': reason,
      'notes': notes,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return BloodRequestModel.fromJson(jsonData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to create request: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Donor accept request
  Future<Map<String, dynamic>> acceptRequest({
    required String requestId,
    required String donorId,
    String? locationId,
    String? notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/donor/accept-request');

    final body = json.encode({
      'requestId': requestId,
      'donorId': donorId,
      'locationId': locationId,
      'notes': notes,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['message'] ??
              'Failed to accept request: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get urgent requests (for donors)
  Future<List<BloodRequestModel>> getUrgentRequests({
    double? latitude,
    double? longitude,
    double radius = 20,
    String? bloodType,
  }) async {
    final uri = Uri.parse('$_baseUrl/blood-requests/urgent').replace(
      queryParameters: {
        if (latitude != null) 'lat': latitude.toString(),
        if (longitude != null) 'lng': longitude.toString(),
        'radius': radius.toString(),
        if (bloodType != null) 'bloodType': bloodType,
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> data = jsonData['data'] as List;
          return data.map((json) => BloodRequestModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // Get supply routes (for hospitals/blood banks)
  Future<List<Map<String, dynamic>>> getSupplyRoutes({
    String? facilityId,
    String? fromId,
    String? toId,
    String? facilityType,
    String? destinationId,
    String status = 'pending',
    bool optimize = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/routes/supply').replace(
      queryParameters: {
        if (facilityId != null) 'facilityId': facilityId,
        if (fromId != null) 'fromId': fromId,
        if (toId != null) 'toId': toId,
        if (facilityType != null) 'facilityType': facilityType,
        if (destinationId != null) 'destinationId': destinationId,
        'status': status,
        'optimize': optimize.toString(),
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return List<Map<String, dynamic>>.from(jsonData['data'] as List);
        }
        return [];
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return 'patient';
      case UserRole.donor:
        return 'donor';
      case UserRole.hospital:
        return 'hospital';
      case UserRole.bloodBank:
        return 'blood_bank';
    }
  }
}
