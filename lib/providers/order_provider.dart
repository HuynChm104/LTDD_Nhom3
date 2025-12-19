import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/zalopay_service.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> placeOrder(OrderModel order) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (order.paymentMethod == 'zalopay') {
        final result = await ZaloPayService.createOrder(order.totalAmount.toInt());
        _isLoading = false;
        notifyListeners();
        if (result != null && result['returncode'] == 1) {
          return result['orderurl'];
        }
        return null;
      } else {
        await _orderService.saveOrder(order);
        _isLoading = false;
        notifyListeners();
        return "success";
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> confirmPaid(OrderModel order) async {
    await _orderService.saveOrder(order);
  }

  Stream<List<OrderModel>> getOrdersStream(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Hủy đơn hàng và gửi thông báo
  Future<bool> cancelOrder(OrderModel order) async {
    try {
      await _firestore.collection('orders').doc(order.id).update({'status': 'cancelled'});

      String notifyBody = "Bạn đã hủy đơn hàng ${order.id.substring(0, 10)}.";
      if ((order.paymentMethod == 'zalopay' || order.paymentMethod == 'banking') && order.isPaid) {
        notifyBody += " Tiền sẽ được hoàn lại trong 24h-48h.";
      }

      await _firestore.collection('notifications').add({
        'title': 'Hủy đơn hàng thành công',
        'body': notifyBody,
        'createdAt': FieldValue.serverTimestamp(),
        // SỬA: Thay isRead: false bằng readBy: [] để đồng bộ phương án A
        'readBy': [],
        'type': 'order',
        'userId': order.userId,
      });

      notifyListeners();
      return true;
    } catch (e) {
      print("Lỗi khi hủy đơn: $e");
      return false;
    }
  }

  // Cập nhật trạng thái và tạo thông báo tương ứng
  Future<void> updateOrderStatusAndNotify(OrderModel order, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(order.id).update({
        'status': newStatus,
      });

      String title = "";
      String body = "";
      switch (newStatus) {
        case 'processing':
          title = "Đơn hàng đã được xác nhận";
          body = "Quán đang chuẩn bị món cho đơn hàng ${order.id.substring(0, 10)}.";
          break;
        case 'shipping':
          title = "Đơn hàng đang giao";
          body = "Tài xế đang mang món đến với bạn đây!";
          break;
        case 'completed':
          title = "Giao hàng thành công";
          body = "Cảm ơn bạn đã ủng hộ Bông Biêng. Chúc bạn ngon miệng!";
          break;
        case 'cancelled':
          title = "Đơn hàng đã hủy";
          body = "Đơn hàng ${order.id.substring(0, 10)} đã bị hủy.";
          break;
      }

      if (title.isNotEmpty) {
        await _firestore.collection('notifications').add({
          'title': title,
          'body': body,
          'createdAt': FieldValue.serverTimestamp(),
          // SỬA: Thay isRead: false bằng readBy: [] để đồng bộ phương án A
          'readBy': [],
          'type': 'order',
          'userId': order.userId,
        });
      }

      notifyListeners();
    } catch (e) {
      print("Lỗi cập nhật trạng thái: $e");
    }
  }
}