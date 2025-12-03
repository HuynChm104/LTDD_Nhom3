// lib/models/voucher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  final String id;
  final String code;
  final String description;
  final double discountPercent;
  final double minOrder;
  final Timestamp expiredAt;
  final bool isActive;

  VoucherModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.minOrder,
    required this.expiredAt,
    required this.isActive,
  });

  factory VoucherModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VoucherModel(
      id: doc.id,
      code: data['code'] ?? '',
      description: data['description'] ?? 'Không có mô tả',
      // Chuyển đổi an toàn từ number sang double
      discountPercent: (data['discountPercent'] ?? 0.0).toDouble(),
      minOrder: (data['minOrder'] ?? 0.0).toDouble(),
      // Đọc Timestamp trực tiếp
      expiredAt: data['expiredAt'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? false,
    );
  }
}
