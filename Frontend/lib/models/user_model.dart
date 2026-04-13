class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String rfid;
  int points;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.rfid,
    this.points = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      rfid: json['rfid_id'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}
