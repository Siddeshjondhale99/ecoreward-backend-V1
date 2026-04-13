import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  int _totalUsers = 0;
  double _totalWasteCollected = 0.0;
  int _totalPointsAwarded = 0;
  Map<String, double> _categoryStats = {'plastic': 0.0, 'wet': 0.0, 'dry': 0.0};
  bool _isLoading = false;

  AdminProvider() {
    loadData();
  }

  int get totalUsersCount => _totalUsers;
  // To avoid breaking AdminDashboard which uses allUsers.length
  List<dynamic> get allUsers => List.generate(_totalUsers, (_) => null); 
  
  double get totalWasteCollected => _totalWasteCollected;
  int get totalPointsAwarded => _totalPointsAwarded;
  Map<String, double> get categoryStats => _categoryStats;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dashboardResponse = await _apiService.get('/admin/dashboard');
      if (dashboardResponse.statusCode == 200) {
        final data = jsonDecode(dashboardResponse.body);
        _totalUsers = data['total_users'];
        _totalWasteCollected = (data['total_waste_kg'] as num).toDouble();
        _totalPointsAwarded = data['total_points_in_circulation'];
      }

      final analyticsResponse = await _apiService.get('/admin/analytics');
      if (analyticsResponse.statusCode == 200) {
        final data = jsonDecode(analyticsResponse.body);
        final stats = data['waste_distribution'] as Map<String, dynamic>;
        _categoryStats = stats.map((key, value) => MapEntry(key, (value as num).toDouble()));
      }
    } catch (e) {
      debugPrint('Error fetching admin data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
