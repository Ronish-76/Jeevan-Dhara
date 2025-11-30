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

  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
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

  Future<void> updateFCMToken(String token) async {
    try {
      await post('auth/fcm-token', {'fcmToken': token});
    } catch (e) {
       print("Failed to update FCM token: $e");
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
    try {
      final response = await get('blood-requests');
      if (response is List) {
         return response.map((e) {
           if (e is Map) {
             if ((e['hospital'] != null && e['hospital'] != 'null' && e['hospital'] != '') || e['requestType'] == 'Hospital') {
                final map = Map<String, dynamic>.from(e);
                map['requestType'] = 'Hospital';
                return map;
             }
           }
           return e;
         }).toList();
      }
      return response as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAllHospitalBloodRequests() async {
    try {
      final response = await get('hospitalbloodrequests');
      if (response is List) {
         return response.map((e) {
           if (e is Map) {
             final map = Map<String, dynamic>.from(e);
             map['requestType'] = 'Hospital';
             return map;
           }
           return e;
         }).toList();
      }
      return response as List<dynamic>;
    } catch (e) {
      // Ignore and try fallback
    }

    // Fallback
    try {
      final hospitals = await get('hospitals');
      if (hospitals is List) {
        final List<dynamic> aggregatedRequests = [];
        await Future.wait(hospitals.map((h) async {
           if (h is Map && h['_id'] != null) {
             try {
               final reqs = await getHospitalBloodRequests(h['_id']);
               if (reqs is List) {
                 for (var r in reqs) {
                   if (r is Map) {
                     r['hospital'] = r['hospital'] ?? h['_id'];
                     if (r['hospitalName'] == null || r['hospitalName'] == '') {
                        r['hospitalName'] = h['hospitalName'] ?? h['fullName'] ?? 'Hospital';
                     }
                     if (r['location'] == null || r['location'] == '') {
                        r['location'] = h['address'] ?? h['location'] ?? h['hospitalLocation'];
                     }
                     if (r['contactNumber'] == null || r['contactNumber'] == '') {
                        r['contactNumber'] = h['phoneNumber'] ?? h['hospitalPhone'];
                     }
                     if (r['latitude'] == null) r['latitude'] = h['latitude'];
                     if (r['longitude'] == null) r['longitude'] = h['longitude'];
                     
                     r['requestType'] = 'Hospital';
                   }
                 }
                 aggregatedRequests.addAll(reqs);
               }
             } catch (_) {}
           }
        }));
        return aggregatedRequests;
      }
    } catch (e) {
      // debugPrint("Fallback fetch failed: $e");
    }
    return []; 
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
    try {
      return await post('blood-requests/accept', {
        'requestId': requestId,
        'donorId': donorId,
      });
    } catch (e) {
      try {
        return await put('blood-requests/$requestId/accept', {'donorId': donorId});
      } catch (_) {
         return await patch('blood-requests/$requestId', {'status': 'accepted', 'donor': donorId, 'donorId': donorId});
      }
    }
  }
  
  Future<dynamic> acceptHospitalBloodRequest(String requestId, String donorId) async {
    final updateData = {
      'status': 'accepted', 
      'donor': donorId, 
      'donorId': donorId,
      'acceptedAt': DateTime.now().toIso8601String(),
    };

    try {
      // Use the new correct route: /hospitals/blood-requests/:requestId
      return await put('hospitals/blood-requests/$requestId', updateData);
    } catch (e) {
       // Fallback
       try {
          return await put('hospitalbloodrequests/$requestId', updateData);
       } catch (e1) {
          try {
             return await patch('hospitalbloodrequests/$requestId', updateData);
          } catch (e2) {
             // ...
             throw e2;
          }
       }
    }
  }

  Future<dynamic> fulfillBloodRequest(String requestId, String? donorId) async {
    final body = <String, dynamic>{'requestId': requestId};
    if (donorId != null) body['donorId'] = donorId;

    try {
      return await post('blood-requests/fulfill', body);
    } catch (e) {
       final patchData = <String, dynamic>{'status': 'fulfilled'};
       if (donorId != null) {
         patchData['donor'] = donorId;
         patchData['donorId'] = donorId;
       }
       return await patch('blood-requests/$requestId', patchData);
    }
  }
  
  Future<dynamic> fulfillHospitalBloodRequest(String requestId, String? donorId) async {
    final data = <String, dynamic>{'status': 'fulfilled'};
    if (donorId != null) {
      data['donor'] = donorId;
      data['donorId'] = donorId;
    }
    
    try {
      // Use the new correct route: /hospitals/blood-requests/:requestId
      return await put('hospitals/blood-requests/$requestId', data);
    } catch (e) {
      try {
        return await put('hospitalbloodrequests/$requestId', data);
      } catch (e) {
         try {
           return await patch('hospitalbloodrequests/$requestId', data);
         } catch (e) {
             final postBody = <String, dynamic>{'requestId': requestId};
             if (donorId != null) postBody['donorId'] = donorId;
             return await post('hospitalbloodrequests/fulfill', postBody);
         }
      }
    }
  }

  // Hospital Endpoints
  Future<dynamic> getHospital(String id) async {
    try {
      return await get('auth/profile/hospital/$id');
    } catch (e) {
      try {
        return await get('hospitals/$id');
      } catch (_) {
        return null;
      }
    }
  }

  Future<List<dynamic>> getHospitalBloodRequests(String hospitalId) async {
    try {
      final response = await get('hospitals/$hospitalId/blood-requests');
      if (response is List) {
        return response.map((e) {
          if (e is Map) {
            final map = Map<String, dynamic>.from(e);
            map['requestType'] = 'Hospital';
            return map;
          }
          return e;
        }).toList();
      }
      return [];
    } catch (e) {
       return [];
    }
  }

  Future<dynamic> createHospitalBloodRequest(String hospitalId, Map<String, dynamic> data) async {
    try {
       return await post('hospitals/$hospitalId/blood-requests', data);
    } catch (e) {
       data['hospital'] = hospitalId;
       return await post('hospitalbloodrequests', data);
    }
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

  Future<List<dynamic>> getHospitalDonations(String hospitalId) async {
    final response = await get('hospitals/$hospitalId/donations');
    return response as List<dynamic>;
  }
}
