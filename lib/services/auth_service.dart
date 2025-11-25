import 'package:jeevandhara/core/constants.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'email': email,
        'password': password,
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('auth/register', userData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // Determine endpoint based on user type if needed, but for now assuming requester
      // Ideally, the endpoint should be generic or passed in.
      // Given the backend change was in requesterRoutes, we use that.
      final response = await _apiService.put('requesters/$userId', updates);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
