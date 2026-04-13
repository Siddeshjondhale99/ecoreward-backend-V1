class RewardCoupon {
  final int id;
  final String title;
  final String description;
  final int pointsRequired;
  final String iconType;

  RewardCoupon({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.iconType,
  });

  factory RewardCoupon.fromJson(Map<String, dynamic> json) {
    return RewardCoupon(
      id: json['id'],
      title: json['name'],
      description: 'Redeem this for ${json['name']} rewards!',
      pointsRequired: json['points_required'],
      iconType: 'stars',
    );
  }
}
