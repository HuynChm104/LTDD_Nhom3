import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toMap());
  }


  Future<void> userCancelOrder(OrderModel order) async {
    final orderRef = _db.collection('orders').doc(order.id);

    await orderRef.update({'status': 'cancelled'});

    String title = "Hủy đơn hàng thành công";
    String body = "Đơn hàng #${order.id.substring(0, 6).toUpperCase()} đã được hủy theo yêu cầu.";

    // KIỂM TRA ĐIỀU KIỆN HOÀN TIỀN
    bool isOnlinePayment = order.paymentMethod == 'zalopay' || order.paymentMethod == 'banking';
    if (order.isPaid && isOnlinePayment) {
      body += "\n💰 Hệ thống đã ghi nhận yêu cầu hoàn tiền của bạn (thời gian xử lý: 24-48h).";
    }

    await _db.collection('notifications').add({
      'title': title,
      'body': body,
      'userId': order.userId,
      'type': 'order',
      'readBy': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}