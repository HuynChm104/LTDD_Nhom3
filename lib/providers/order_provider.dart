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
          return result['orderurl'].toString();
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

  // lib/providers/order_provider.dart

  Future<bool> cancelOrder(OrderModel order) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.userCancelOrder(order);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Lỗi hủy đơn: $e");
      return false;
    }
  }
}