<<<<<<< HEAD
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jeevandhara/models/user_model.dart';
import 'package:jeevandhara/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final data = await _authService.login(email, password);
      
      final token = data['token'];
      final userData = data['user'];
      
      if (token != null && userData != null) {
        _user = User.fromJson(userData);
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userData));
        
        _setLoading(false);
        return true;
      } else {
        _errorMessage = "Invalid response from server";
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    try {
      final data = await _authService.register(userData);
      
      // Check if backend returned token (auto-login supported)
      if (data.containsKey('token') && data['token'] != null && data.containsKey('user')) {
        final token = data['token'];
        final userResponseData = data['user'];
        
        _user = User.fromJson(userResponseData);
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(userResponseData));
      } 
      // If no token, it means registration was successful but requires manual login
      // which matches the current backend behavior
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_user == null || _user!.id == null) return false;
    _setLoading(true);
    try {
      final data = await _authService.updateProfile(_user!.id!, updates);
      
      final userResponseData = data['user'];
      if (userResponseData != null) {
        _user = User.fromJson(userResponseData);
        
        // Update SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(userResponseData));
        
        _setLoading(false);
        return true;
      } else {
         // Assume update success but no data returned?
         _setLoading(false);
         return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;

    final userDataString = prefs.getString('user');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }
}
=======

>>>>>>> map-feature
