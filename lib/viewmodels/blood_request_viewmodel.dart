// lib/viewmodels/blood_request_viewmodel.dart

import '../models/blood_request_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'base_viewmodel.dart';

/// ViewModel for managing blood request state and business logic
class BloodRequestViewModel extends BaseViewModel {
  BloodRequestViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService.instance {
    _initializeSocket();
  }

  final ApiService _apiService;

  List<BloodRequestModel> _requests = const [];
  BloodRequestModel? _selectedRequest;

  // --- Existing Getters (Good) ---
  List<BloodRequestModel> get requests => _requests;
  BloodRequestModel? get selectedRequest => _selectedRequest;
  int get totalRequests => _requests.length;
  int get pendingRequests =>
      _requests.where((r) => r.status == 'pending').length;
  int get fulfilledRequests =>
      _requests.where((r) => r.status == 'responded').length;

  // --- FIX: Add the getters and methods the UI is expecting ---

  // FIX #1: The UI is asking for `isLoading`, which is managed by BaseViewModel.
  // We can expose it here if BaseViewModel doesn't already. Assuming BaseViewModel has `bool get isLoading`.
  // If not, the `setLoading` in your BaseViewModel should be paired with a `get isLoading`.
  // Your BaseViewModel likely already handles this, so this getter might be redundant, but it ensures compatibility.
  // bool get isLoading => super.isLoading; // This is how you would expose it if needed. Your code already does this via `extends BaseViewModel`.

  // FIX #2: Add a new getter named `activeRequests` that points to the existing `_requests` list.
  List<BloodRequestModel> get activeRequests => _requests;

  // FIX #3: Add a new method named `loadActiveRequests` that calls your existing `fetchActiveRequests`.
  Future<void> loadActiveRequests({bool forceRefresh = false}) async {
    // This just calls your already-written logic.
    return fetchActiveRequests(forceRefresh: forceRefresh);
  }
  // --- End of Fixes ---


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

  /// Fetch all active blood requests
  Future<void> fetchActiveRequests({bool forceRefresh = false}) async {
    // This is your original, correct logic. No changes needed here.
    if (isLoading && !forceRefresh) return;
    if (!forceRefresh && _requests.isNotEmpty) return;

    setLoading(true);
    clearError();
    try {
      final data = await _apiService.fetchActiveRequests();
      _requests = data;
    } catch (error) {
      setError(error.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Submit a new blood request
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
    // This method is fine, no changes needed.
    setLoading(true);
    clearError();
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

      _upsertRequest(created);
      return created;
    } catch (error) {
      setError(error.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Respond to a blood request
  Future<BloodRequestModel?> respondToRequest({
    required String requestId,
    required String responderRole,
    required String responderName,
    String? responderContact,
    String? notes,
  }) async {
    // This method is fine, no changes needed.
    setLoading(true);
    clearError();
    try {
      final updated = await _apiService.respondToRequest(
        requestId: requestId,
        responderRole: responderRole,
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

  /// Select a request for viewing details
  void selectRequest(BloodRequestModel request) {
    _selectedRequest = request;
    notifyListeners();
  }

  /// Clear selected request
  void clearSelection() {
    _selectedRequest = null;
    notifyListeners();
  }

  /// Filter requests by status
  List<BloodRequestModel> getRequestsByStatus(String status) {
    return _requests.where((r) => r.status == status).toList();
  }

  /// Filter requests by blood type
  List<BloodRequestModel> getRequestsByBloodType(String bloodType) {
    // There might be an old error here. Ensure your BloodRequestModel uses bloodGroup.
    return _requests.where((r) => r.bloodGroup == bloodType).toList();
  }

  /// Update or insert a request (used by socket updates)
  void _upsertRequest(BloodRequestModel request) {
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

  @override
  void dispose() {
    SocketService.instance.dispose();
    super.dispose();
  }
}
