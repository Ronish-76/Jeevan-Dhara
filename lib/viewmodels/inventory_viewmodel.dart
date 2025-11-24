import 'package:geolocator/geolocator.dart';

import '../models/location_model.dart';
import '../services/map_service.dart';
import 'base_viewmodel.dart';

/// ViewModel for managing inventory and facility state
class InventoryViewModel extends BaseViewModel {
  InventoryViewModel({MapService? mapService})
      : _mapService = mapService ?? MapService();

  final MapService _mapService;

  List<LocationModel> _nearbyFacilities = const [];
  Map<String, int> _inventory = {};
  Position? _lastPosition;
  UserRole? _currentRole;

  List<LocationModel> get nearbyFacilities => _nearbyFacilities;
  Map<String, int> get inventory => _inventory;
  Position? get lastPosition => _lastPosition;
  UserRole? get currentRole => _currentRole;

  int get totalInventoryUnits =>
      _inventory.values.fold(0, (sum, units) => sum + units);
  int get lowStockCount => _inventory.entries
      .where((entry) => entry.value < 5)
      .length;
  int get criticalStockCount => _inventory.entries
      .where((entry) => entry.value < 2)
      .length;

  /// Fetch nearby facilities based on role
  Future<void> fetchNearbyFacilities({
    required UserRole role,
    double radiusKm = 10,
    bool forceRefresh = false,
  }) async {
    if (isLoading && !forceRefresh) return;
    if (!forceRefresh && _nearbyFacilities.isNotEmpty && _currentRole == role) {
      return;
    }

    setLoading(true);
    clearError();
    try {
      final position = await _determinePosition();
      _lastPosition = position;
      _currentRole = role;

      final facilities = await _mapService.getNearbyLocations(
        latitude: position.latitude,
        longitude: position.longitude,
        role: role,
        radius: radiusKm,
      );
      _nearbyFacilities = facilities;
    } catch (error) {
      setError(error.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Fetch inventory for a specific facility
  Future<Map<String, int>?> fetchFacilityInventory(String facilityId) async {
    setLoading(true);
    clearError();
    try {
      final data = await _mapService.getBloodBankInventory(facilityId);
      _inventory = Map<String, int>.from(data['inventory'] ?? {});
      return data['inventory'] as Map<String, int>?;
    } catch (error) {
      setError(error.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Get facilities by blood type availability
  List<LocationModel> getFacilitiesWithBloodType(String bloodType) {
    return _nearbyFacilities.where((facility) {
      final inv = facility.inventory;
      return inv != null && inv.containsKey(bloodType) && inv[bloodType]! > 0;
    }).toList();
  }

  /// Get facilities with low stock
  List<LocationModel> getFacilitiesWithLowStock() {
    return _nearbyFacilities.where((facility) {
      final inv = facility.inventory;
      if (inv == null) return false;
      return inv.values.any((units) => units < 5);
    }).toList();
  }

  /// Get current facility (first in list if available)
  LocationModel? get currentFacility =>
      _nearbyFacilities.isNotEmpty ? _nearbyFacilities.first : null;

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

