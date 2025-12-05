// lib/services/notification_service.dart
// Chịu trách nhiệm lấy dữ liệu và đánh dấu đã đọc
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Lấy danh sách thông báo (Realtime Stream)
  // Sắp xếp theo thời gian mới nhất lên đầu
  static Stream<List<NotificationModel>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
    });
  }

  // 2. Lấy số lượng tin chưa đọc (để hiện lên chấm đỏ ở quả chuông)
  static Stream<int> getUnreadCount() {
    return _firestore
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 3. Hàm đánh dấu đã đọc (khi người dùng bấm vào xem)
  static Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).update({
      'isRead': true,
    });
  }

  // 4. Hàm đánh dấu đã đọc tất cả
  static Future<void> markAllAsRead() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('notifications').where('isRead', isEqualTo: false).get();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}