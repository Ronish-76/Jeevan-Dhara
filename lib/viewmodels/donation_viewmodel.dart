import '../models/donation_model.dart';
import '../services/donor_service.dart';
import 'base_viewmodel.dart';

/// ViewModel for managing donation state and business logic
class DonationViewModel extends BaseViewModel {
  DonationViewModel({DonorService? donorService})
      : _donorService = donorService ?? DonorService.instance;

  final DonorService _donorService;

  List<DonationModel> _donations = const [];
  DonationModel? _selectedDonation;

  List<DonationModel> get donations => _donations;
  DonationModel? get selectedDonation => _selectedDonation;
  int get totalDonations => _donations.length;

  /// Fetch donation history with optional filters
  Future<void> fetchDonationHistory({
    String? donorId,
    bool forceRefresh = false,
  }) async {
    if (isLoading && !forceRefresh) return;
    if (donorId == null) {
      setError('Donor ID is required');
      return;
    }

    setLoading(true);
    clearError();
    try {
      final data = await _donorService.getDonationHistory(donorId);
      // Convert DonationRecord to DonationModel
      _donations = data.map((record) => DonationModel(
        id: record.id,
        donorId: record.donorId,
        donorName: '', // Not available in DonationRecord
        bloodType: record.bloodType,
        facilityId: '', // Not available in DonationRecord
        facilityName: record.location ?? '',
        units: record.units,
        donationDate: record.donationDate,
        status: 'completed', // Assume completed if in history
        notes: record.notes,
        createdAt: record.donationDate,
        updatedAt: record.donationDate,
      )).toList();
    } catch (error) {
      setError(error.toString());
    } finally {
      setLoading(false);
    }
  }

  /// Create a new donation record
  /// Note: This functionality may need backend API implementation
  Future<DonationModel?> createDonation({
    required String donorId,
    required String donorName,
    required String bloodType,
    required String facilityId,
    required String facilityName,
    required int quantity,
    required DateTime donationDate,
    String? notes,
  }) async {
    setLoading(true);
    clearError();
    try {
      // TODO: Implement createDonation in backend API
      // For now, create a local model
      final now = DateTime.now();
      final created = DonationModel(
        id: now.millisecondsSinceEpoch.toString(),
        donorId: donorId,
        donorName: donorName,
        bloodType: bloodType,
        facilityId: facilityId,
        facilityName: facilityName,
        units: quantity,
        donationDate: donationDate,
        status: 'pending',
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      _upsertDonation(created);
      return created;
    } catch (error) {
      setError(error.toString());
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Select a donation for viewing details
  void selectDonation(DonationModel donation) {
    _selectedDonation = donation;
    notifyListeners();
  }

  /// Clear selected donation
  void clearSelection() {
    _selectedDonation = null;
    notifyListeners();
  }

  /// Filter donations by status
  List<DonationModel> getDonationsByStatus(String status) {
    return _donations.where((d) => d.status == status).toList();
  }

  /// Filter donations by blood type
  List<DonationModel> getDonationsByBloodType(String bloodType) {
    return _donations.where((d) => d.bloodType == bloodType).toList();
  }

  /// Get donations for a specific facility
  List<DonationModel> getDonationsByFacility(String facilityId) {
    return _donations.where((d) => d.facilityId == facilityId).toList();
  }

  /// Get donations for a specific donor
  List<DonationModel> getDonationsByDonor(String donorId) {
    return _donations.where((d) => d.donorId == donorId).toList();
  }

  /// Update or insert a donation
  void _upsertDonation(DonationModel donation) {
    final idx = _donations.indexWhere((item) => item.id == donation.id);
    if (idx >= 0) {
      final copy = [..._donations];
      copy[idx] = donation;
      _donations = copy;
    } else {
      _donations = [donation, ..._donations];
    }
    notifyListeners();
  }
}

