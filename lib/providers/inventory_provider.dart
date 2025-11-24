import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';
import '../services/map_service.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider({MapService? mapService})
    : _mapService = mapService ?? MapService();

  final MapService _mapService;

  List<LocationModel> _nearbyFacilities = const [];
  bool _isLoading = false;
  String? _error;
  Position? _lastPosition;

  List<LocationModel> get nearbyFacilities => _nearbyFacilities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get lastPosition => _lastPosition;

  Future<void> fetchNearbyFacilities({
    required UserRole role,
    double radiusKm = 10,
    bool forceRefresh = false,
  }) async {
    if (_isLoading && !forceRefresh) return;
    if (!forceRefresh && _nearbyFacilities.isNotEmpty) return;
    _setLoading(true);
    try {
      final position = await _determinePosition();
      _lastPosition = position;
      final facilities = await _mapService.getNearbyLocations(
        latitude: position.latitude,
        longitude: position.longitude,
        role: role,
        radius: radiusKm,
      );
      _nearbyFacilities = facilities;
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> fetchInventory(String facilityId) async {
    try {
      return await _mapService.getBloodBankInventory(facilityId);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Enable location services to load nearby facilities.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required.');
    }
    return Geolocator.getCurrentPosition();
  }
}
