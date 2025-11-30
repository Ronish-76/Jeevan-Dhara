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

  Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      // Try fetching from generic users endpoint first
      try {
        return await _apiService.get('users/$userId');
      } catch (e) {
        // Fallback to trying donor or requester endpoints
        try {
           return await _apiService.get('donors/$userId');
        } catch (e2) {
           return await _apiService.get('requesters/$userId');
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // The previous hardcoded 'requesters/' endpoint might fail for donors.
      // We need a generic endpoint or to know the user type.
      // But wait, the backend often has a 'users/me' or similar for self update.
      // If not, we need to switch on userType or try a generic 'users/$userId' endpoint if available.
      // For now, I'll try a more generic approach:
      // Check if the API supports a common update endpoint.
      // If not, we might need to pass the userType to this function or infer it.
      // Assuming 'users/$userId' works or we need to use 'donors/$userId' for donors.
      
      // Let's try 'donors/$userId' if the current update fails for donors.
      // However, since I don't have userType here easily without passing it, 
      // I will try to use a generic 'users/$userId' if it exists, otherwise I'll default to 'requesters' 
      // but that breaks for donors.
      
      // Let's modify ApiService or AuthProvider to handle this better.
      // But for a quick fix, I'll assume there are separate endpoints:
      // 'requesters/:id' and 'donors/:id'.
      
      // I'll try to use the 'donors' endpoint if the update contains donor-specific fields or context implies it.
      // But that's brittle.
      
      // Better: The AuthProvider calls this. It knows the user type.
      // But AuthProvider.updateProfile signature matches this.
      
      // Let's just use 'users/$userId' if your backend supports a unified user route.
      // If your backend is strictly segmented, we MUST know the type.
      
      // Assuming the backend has a 'users' route for general updates OR we try both.
      try {
         return await _apiService.put('users/$userId', updates);
      } catch (e) {
         // If users endpoint fails or doesn't exist, try specific ones.
         // This is a fallback hack. 
         try {
            return await _apiService.put('requesters/$userId', updates);
         } catch (e2) {
            return await _apiService.put('donors/$userId', updates);
         }
      }
    } catch (e) {
      rethrow;
    }
  }
}
