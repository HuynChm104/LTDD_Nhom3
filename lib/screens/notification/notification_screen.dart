import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy userId hiện tại để truyền vào các hàm xử lý
    final userId = Provider.of<AuthProvider>(context).user?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            // Cập nhật: Truyền userId để chỉ đánh dấu "Đọc tất cả" cho riêng user này
            onPressed: () => NotificationService.markAllAsRead(userId),
            child: const Text(
              "Đọc tất cả",
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService.getNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có thông báo nào",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              // Truyền thêm userId vào hàm build item
              return _buildNotificationItem(notifications[index], userId);
            },
          );
        },
      ),
    );
  }

  // CẬP NHẬT THAM SỐ: Nhận thêm userId
  Widget _buildNotificationItem(NotificationModel notif, String userId) {
    IconData iconData;
    Color iconColor;

    switch (notif.type) {
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.orange;
        break;
      case 'order':
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.primary;
    }

    // Sử dụng hàm helper từ model để kiểm tra user hiện tại đã đọc tin này chưa
    final bool isRead = notif.isReadByUser(userId);

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          // Cập nhật: Truyền ID thông báo và userId để thêm vào mảng readBy
          NotificationService.markAsRead(notif.id, userId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Màu nền thay đổi dựa trên trạng thái đọc của user hiện tại
          color: isRead ? Colors.white : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: isRead
              ? Border.all(color: Colors.grey.withOpacity(0.2))
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            color: isRead ? Colors.black87 : Colors.black,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.body,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd/MM HH:mm').format(notif.createdAt),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}