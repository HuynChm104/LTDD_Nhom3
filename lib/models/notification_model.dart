// lib/models/notification_model.dart
// tạo model hứng dữ liệu noti
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final List<String> readBy;
  final String type; // 'promotion', 'order', 'system'
  final String userId;


  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.readBy,
    required this.type,
    required this.userId,
  });

  // Helper để kiểm tra nhanh một user đã đọc chưa
  bool isReadByUser(String currentUserId) {
    return readBy.contains(currentUserId);
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? 'Thông báo',
      body: data['body'] ?? 'Không có nội dung',
      // Xử lý Timestamp của Firebase chuyển về DateTime của Dart
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readBy: List<String>.from(data['readBy'] ?? []),
      type: data['type'] ?? 'system',
      userId: data['userId']?.toString() ?? '',
    );
  }
}