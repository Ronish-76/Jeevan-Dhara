// lib/viewmodels/base_viewmodel.dart

import 'package:flutter/foundation.dart';

class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    if (_isLoading == loading) return; // Prevent unnecessary rebuilds
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    if (_error == error) return; // Prevent unnecessary rebuilds
    _error = error;
    // FIX: Notify listeners so the UI can react to a new error.
    notifyListeners();
  }

  void clearError() {
    if (_error == null) return; // Prevent unnecessary rebuilds
    _error = null;
    // FIX: Notify listeners so the UI knows the error has been cleared.
    notifyListeners();
  }
}
