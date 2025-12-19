import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveOrder(OrderModel order) async {
    await _db.collection('orders').doc(order.id).set(order.toMap());
  }
}