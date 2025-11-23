import 'package:flutter/foundation.dart';

import '../models/blood_request_model.dart';
import '../services/api_service.dart';

class RequestProvider extends ChangeNotifier {
  RequestProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService.instance;

  final ApiService _apiService;

  List<BloodRequestModel> _requests = const [];
  bool _isLoading = false;
  String? _error;

  List<BloodRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchActiveRequests({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh && _requests.isNotEmpty) return;

    _setLoading(true);
    try {
      final data = await _apiService.fetchActiveRequests();
      _requests = data;
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<BloodRequestModel?> submitRequest({
    required String requesterRole,
    required String requesterName,
    required String requesterContact,
    required String bloodGroup,
    required int units,
    required double lat,
    required double lng,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final created = await _apiService.createBloodRequest(
        requesterRole: requesterRole,
        requesterName: requesterName,
        requesterContact: requesterContact,
        bloodGroup: bloodGroup,
        units: units,
        lat: lat,
        lng: lng,
        notes: notes,
      );

      _upsert(created);
      _error = null;
      return created;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _upsert(BloodRequestModel request) {
    final idx = _requests.indexWhere((item) => item.id == request.id);
    if (idx >= 0) {
      final copy = [..._requests];
      copy[idx] = request;
      _requests = copy;
    } else {
      _requests = [request, ..._requests];
    }
    notifyListeners();
  }

  void setFromSocket(BloodRequestModel request) {
    _upsert(request);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
