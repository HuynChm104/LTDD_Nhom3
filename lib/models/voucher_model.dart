// models/voucher_model.dart
class VoucherModel {
  final String id;
  final String code;
  final double discountPercent;
  final double minOrder;
  final DateTime expiredAt;
  final bool isActive;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.minOrder,
    required this.expiredAt,
    required this.isActive,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      discountPercent: json['discountPercent'] ?? '',
      minOrder: json['minOrder'] ?? '',
      expiredAt: DateTime.parse(json['expiredAt']) ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }
}
