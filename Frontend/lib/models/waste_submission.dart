class WasteSubmission {
  final int id;
  final int userId;
  final DateTime date;
  final String category; // 'dry', 'wet', 'plastic'
  final double weightKg;
  final int pointsEarned;

  WasteSubmission({
    required this.id,
    required this.userId,
    required this.date,
    required this.category,
    required this.weightKg,
    required this.pointsEarned,
  });

  factory WasteSubmission.fromJson(Map<String, dynamic> json) {
    return WasteSubmission(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['timestamp']),
      category: json['waste_type'],
      weightKg: (json['weight'] as num).toDouble(),
      pointsEarned: json['points_earned'],
    );
  }
}
