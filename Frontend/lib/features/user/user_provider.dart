import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/waste_submission.dart';
import '../../models/reward_coupon.dart';
import '../../models/redeemed_voucher.dart';
import '../../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserModel? currentUser;
  
  List<WasteSubmission> _mySubmissions = [];
  List<RewardCoupon> _availableCoupons = [];
  List<RedeemedVoucher> _myVouchers = [];
  bool _isLoading = false;

  UserProvider(this.currentUser) {
    if (currentUser != null) {
      loadData();
    }
  }

  List<WasteSubmission> get mySubmissions => _mySubmissions;
  List<RewardCoupon> get availableCoupons => _availableCoupons;
  List<RedeemedVoucher> get myVouchers => _myVouchers;
  bool get isLoading => _isLoading;
  int get totalPoints => currentUser?.points ?? 0;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    await fetchHistory();
    await fetchRewards();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    try {
      final response = await _apiService.get('/user/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _mySubmissions = data.map((json) => WasteSubmission.fromJson(json)).toList();
        _mySubmissions.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }

  Future<void> fetchRewards() async {
    try {
      final response = await _apiService.get('/rewards', authenticated: false);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _availableCoupons = data.map((json) => RewardCoupon.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching rewards: $e');
    }
  }

  double get todaysWasteWeight {
    final today = DateTime.now();
    return _mySubmissions
        .where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day)
        .fold(0.0, (sum, s) => sum + s.weightKg);
  }

  Map<String, double> get categoryBreakdown {
    final breakdown = {'dry': 0.0, 'wet': 0.0, 'plastic': 0.0};
    for (var s in _mySubmissions) {
      final cat = s.category.toLowerCase();
      if (breakdown.containsKey(cat)) {
        breakdown[cat] = (breakdown[cat] ?? 0.0) + s.weightKg;
      }
    }
    return breakdown;
  }

  Future<String?> redeemCoupon(RewardCoupon coupon) async {
    if (currentUser == null || currentUser!.points < coupon.pointsRequired) return null;

    try {
      final response = await _apiService.post('/redeem/${coupon.id}', {}, authenticated: true);
      
      if (response.statusCode == 200) {
        final voucher = RedeemedVoucher.fromJson(jsonDecode(response.body));
        _myVouchers.add(voucher);
        currentUser!.points -= coupon.pointsRequired;
        notifyListeners();
        return voucher.code;
      }
    } catch (e) {
      debugPrint('Error redeeming coupon: $e');
    }
    return null;
  }
}
