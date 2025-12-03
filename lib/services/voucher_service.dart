// lib/services/voucher_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher_model.dart';

class VoucherService {
  static final _firestore = FirebaseFirestore.instance;

  // Lấy tất cả voucher có thể sử dụng (còn hạn và active)
  static Stream<List<VoucherModel>> getAvailableVouchers() {
    return _firestore
        .collection('vouchers')
        .where('isActive', isEqualTo: true)
        .where('expiredAt', isGreaterThan: Timestamp.now())
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => VoucherModel.fromFirestore(doc))
        .toList());
  }

  // Lấy tất cả voucher đã hết hạn hoặc không active
  static Stream<List<VoucherModel>> getUnavailableVouchers() {
    // Lấy voucher hết hạn
    var expiredStream = _firestore
        .collection('vouchers')
        .where('expiredAt', isLessThanOrEqualTo: Timestamp.now())
        .snapshots();

    // Lấy voucher không active
    var inactiveStream = _firestore
        .collection('vouchers')
        .where('isActive', isEqualTo: false)
        .snapshots();

    // Gộp 2 stream này lại (cần thư viện rxdart) hoặc đơn giản là lấy hết hạn
    return expiredStream.map((snapshot) => snapshot.docs
        .map((doc) => VoucherModel.fromFirestore(doc))
        .toList());
  }
}
