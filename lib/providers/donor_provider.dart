import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/blood_request_model.dart';
import '../services/api_service.dart';
import '../services/map_service.dart';

class DonorProvider extends ChangeNotifier {
  DonorProvider({MapService? mapService, ApiService? apiService})
    : _mapService = mapService ?? MapService(),
      _apiService = apiService ?? ApiService.instance;

  final MapService _mapService;
  final ApiService _apiService;

  List<BloodRequestModel> _urgentRequests = const [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  List<BloodRequestModel> get urgentRequests => _urgentRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  Future<void> loadUrgentRequests({
    bool useLocation = true,
    String? bloodType,
  }) async {
    if (_isLoading) return;
    _setLoading(true);
    try {
      double? lat;
      double? lng;
      if (useLocation) {
        final position = await _determinePosition();
        lat = position?.latitude;
        lng = position?.longitude;
        _currentPosition = position;
      }

      final requests = await _mapService.getUrgentRequests(
        latitude: lat,
        longitude: lng,
        bloodType: bloodType,
      );
      _urgentRequests = requests;
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<BloodRequestModel?> respondToRequest({
    required BloodRequestModel request,
    required String responderName,
    String? responderContact,
    String? notes,
  }) async {
    try {
      final updated = await _apiService.respondToRequest(
        requestId: request.id,
        responderRole: 'donor',
        responderName: responderName,
        responderContact: responderContact,
        notes: notes,
      );
      _upsert(updated);
      return updated;
    } catch (error) {
      _error = error.toString();
      rethrow;
    }
  }

  void updateFromSocket(BloodRequestModel request) {
    _upsert(request);
  }

  void _upsert(BloodRequestModel request) {
    final idx = _urgentRequests.indexWhere(
      (element) => element.id == request.id,
    );
    if (idx >= 0) {
      final copy = [..._urgentRequests];
      copy[idx] = request;
      _urgentRequests = copy;
    } else {
      _urgentRequests = [request, ..._urgentRequests];
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }
}
