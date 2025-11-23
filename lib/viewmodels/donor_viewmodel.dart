import 'package:geolocator/geolocator.dart';

// FIX: Import the DonorModel
import '../models/donor_model.dart';
import '../models/blood_request_model.dart';
import '../services/api_service.dart';
import '../services/map_service.dart';
import '../services/socket_service.dart';
import 'base_viewmodel.dart';

/// ViewModel for managing donor-specific state and business logic
class DonorViewModel extends BaseViewModel {
  DonorViewModel({
    MapService? mapService,
    ApiService? apiService,
  })  : _mapService = mapService ?? MapService(),
        _apiService = apiService ?? ApiService.instance {
    _initializeSocket();
  }

  final MapService _mapService;
  final ApiService _apiService;

  // --- Existing properties for Blood Requests ---
  List<BloodRequestModel> _urgentRequests = const [];
  Position? _currentPosition;
  String? _selectedBloodType;

  List<BloodRequestModel> get urgentRequests => _urgentRequests;
  Position? get currentPosition => _currentPosition;
  String? get selectedBloodType => _selectedBloodType;
  int get totalUrgentRequests => _urgentRequests.length;

  // --- FIX 1: Add properties for Nearby Donors ---
  List<DonorModel> _nearbyDonors = [];
  List<DonorModel> get nearbyDonors => _nearbyDonors;

  // --- Existing Methods for Blood Requests ---
  void _initializeSocket() {
    SocketService.instance.connect(
      onRequestCreated: _handleRequestCreated,
      onRequestResponded: _handleRequestResponded,
    );
  }

  void _handleRequestCreated(BloodRequestModel request) {
    _upsertRequest(request);
  }

  void _handleRequestResponded(BloodRequestModel request) {
    _upsertRequest(request);
  }

  Future<void> loadUrgentRequests({
    bool useLocation = true,
    String? bloodType,
  }) async {
    if (isLoading) return;

    setLoading(true);
    clearError();
    try {
      double? lat;
      double? lng;
      if (useLocation) {
        final position = await _determinePosition();
        lat = position?.latitude;
        lng = position?.longitude;
        _currentPosition = position;
      }

      _selectedBloodType = bloodType;
      final requests = await _mapService.getUrgentRequests(
        latitude: lat,
        longitude: lng,
        bloodType: bloodType,
      );
      _urgentRequests = requests;
    } catch (error) {
      setError(error.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<BloodRequestModel?> respondToRequest({
    required BloodRequestModel request,
    required String responderName,
    String? responderContact,
    String? notes,
  }) async {
    setLoading(true);
    clearError();
    try {
      final updated = await _apiService.respondToRequest(
        requestId: request.id,
        responderRole: 'donor',
        responderName: responderName,
        responderContact: responderContact,
        notes: notes,
      );
      _upsertRequest(updated);
      return updated;
    } catch (error) {
      setError(error.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  void _upsertRequest(BloodRequestModel request) {
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


  // --- FIX 2: Add the method to load nearby donors ---
  /// Load available donors near the user's location
  Future<void> loadNearbyDonors({String? bloodType}) async {
    if (isLoading) return;
    setLoading(true);
    clearError();

    try {
      final position = await _determinePosition();
      // Assume your API/Service can handle a null position
      final donors = await _apiService.getNearbyDonors(
        latitude: position?.latitude,
        longitude: position?.longitude,
        bloodType: bloodType,
      );
      _nearbyDonors = donors;
    } catch (error) {
      setError(error.toString());
      _nearbyDonors = []; // Clear list on error
    } finally {
      setLoading(false);
    }
  }


  // --- Helper and Dispose Methods (no changes needed) ---
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

  @override
  void dispose() {
    SocketService.instance.dispose();
    super.dispose();
  }
}
