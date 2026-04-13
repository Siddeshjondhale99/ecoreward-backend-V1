import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAdmin => _currentUser?.role == AppConstants.roleAdmin;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.postForm('/login', {
        'username': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _apiService.saveToken(data['access_token']);
        return await fetchProfile();
      } else {
        String message = 'Login failed';
        try {
          final data = jsonDecode(response.body);
          message = data['detail'] ?? message;
        } catch (_) {
          message = 'Server Error: ${response.statusCode}';
        }
        throw Exception(message);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchProfile() async {
    try {
      final response = await _apiService.get('/user/profile', authenticated: true);
      
      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(jsonDecode(response.body));
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/signup', {
        'name': name,
        'email': email,
        'password': password,
        'rfid_id': 'RFID-${DateTime.now().millisecondsSinceEpoch}', // Temporary RFID generation
      });

      if (response.statusCode == 200) {
        return await login(email, password);
      } else {
        String message = 'Registration failed';
        try {
          final data = jsonDecode(response.body);
          message = data['detail'] ?? message;
        } catch (_) {
          message = 'Server Error: ${response.statusCode}';
        }
        throw Exception(message);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
