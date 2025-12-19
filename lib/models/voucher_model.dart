// lib/models/voucher_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum VoucherType { bill, shipping, product }

class VoucherModel {
  final String id;
  final String code;
  final String description;
  final double discountPercent;
  final double minOrder;
  final Timestamp expiredAt;
  final bool isActive;
  final VoucherType type; // Loại voucher
  final List<String>? applicableProductIds; // Danh sách ID sản phẩm được áp dụng (nếu type là product)

  VoucherModel({
    required this.id,
    required this.code,
    required this.description,
    required this.discountPercent,
    required this.minOrder,
    required this.expiredAt,
    required this.isActive,
    required this.type,
    this.applicableProductIds,
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
      // Chuyển đổi String từ Firestore sang Enum
      type: VoucherType.values.firstWhere(
            (e) => e.toString().split('.').last == (data['type'] ?? 'bill'),
        orElse: () => VoucherType.bill,
      ),
      applicableProductIds: data['applicableProductIds'] != null
          ? List<String>.from(data['applicableProductIds'])
          : null,
    );
  }
}
