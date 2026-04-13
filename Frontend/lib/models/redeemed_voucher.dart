class RedeemedVoucher {
  final int id;
  final int couponId;
  final String title;
  final String code;
  final DateTime date;

  RedeemedVoucher({
    required this.id,
    required this.couponId,
    required this.title,
    required this.code,
    required this.date,
  });

  factory RedeemedVoucher.fromJson(Map<String, dynamic> json) {
    return RedeemedVoucher(
      id: json['id'],
      couponId: json['reward_id'],
      title: 'Voucher #${json['id']}',
      code: json['voucher_code'],
      date: DateTime.parse(json['timestamp']),
    );
  }
}
