import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Lấy danh sách thông báo Realtime
  static Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .where((n) => n.userId == userId || n.userId == 'all' || n.userId == '')
          .toList();
    });
  }

  // 2. Đếm số tin chưa đọc (Kiểm tra xem userId có trong mảng readBy chưa)
  static Stream<int> getUnreadCount(String userId) {
    if (userId.isEmpty) return Stream.value(0);

    return _firestore.collection('notifications').snapshots().map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final List readBy = data['readBy'] ?? [];
        final String uId = data['userId']?.toString() ?? '';

        // Tin chưa đọc là tin:
        // - Thuộc về user này (hoặc 'all')
        // - VÀ ID của user này CHƯA có trong mảng readBy
        bool isForMe = (uId == userId || uId == 'all' || uId == '');
        bool notReadYet = !readBy.contains(userId);

        return isForMe && notReadYet;
      }).length;
    });
  }

  // 3. Đánh dấu đã đọc: Thêm userId vào mảng readBy bằng FieldValue.arrayUnion
  static Future<void> markAsRead(String notificationId, String userId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }

  // 4. Đánh dấu tất cả là đã đọc
  static Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      final String uId = doc.data()['userId']?.toString() ?? '';
      if (uId == userId || uId == 'all' || uId == '') {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId])
        });
      }
    }
    await batch.commit();
  }
}