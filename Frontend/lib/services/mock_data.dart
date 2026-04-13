import '../models/user_model.dart';
import '../models/waste_submission.dart';
import '../models/reward_coupon.dart';
import '../core/constants.dart';

class MockData {
  static final List<UserModel> users = [
    UserModel(
      id: '1',
      name: 'Admin User',
      email: 'admin@test.com',
      role: AppConstants.roleAdmin,
      rfid: 'ADM-001',
    ),
    UserModel(
      id: '2',
      name: 'John Doe',
      email: 'user@test.com',
      role: AppConstants.roleUser,
      rfid: 'USR-2023',
      points: 450,
    ),
    UserModel(
      id: '3',
      name: 'Jane Smith',
      email: 'jane@test.com',
      role: AppConstants.roleUser,
      rfid: 'USR-2024',
      points: 120,
    ),
  ];

  static final List<WasteSubmission> submissions = [
    WasteSubmission(id: 1, userId: 2, date: DateTime.now().subtract(const Duration(days: 1)), category: 'dry', weightKg: 2.5, pointsEarned: 25),
    WasteSubmission(id: 2, userId: 2, date: DateTime.now().subtract(const Duration(days: 2)), category: 'plastic', weightKg: 1.2, pointsEarned: 36),
    WasteSubmission(id: 3, userId: 2, date: DateTime.now(), category: 'wet', weightKg: 3.0, pointsEarned: 15),
    WasteSubmission(id: 4, userId: 3, date: DateTime.now(), category: 'dry', weightKg: 1.5, pointsEarned: 15),
  ];

  static final List<RewardCoupon> coupons = [
    RewardCoupon(id: 1, title: '$5 Electricity Bill', description: 'Get $5 off your next electricity bill.', pointsRequired: 200, iconType: 'electricity'),
    RewardCoupon(id: 2, title: '$10 Water Bill', description: 'Get $10 off your water bill.', pointsRequired: 350, iconType: 'water'),
    RewardCoupon(id: 3, title: 'Free Coffee', description: 'Redeem for a free coffee at local store.', pointsRequired: 100, iconType: 'coffee'),
  ];
}
