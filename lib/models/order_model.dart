import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String address;
  final String paymentMethod;
  final List<Map<String, dynamic>> items; // Chứa chi tiết sản phẩm
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String status;
  final bool isPaid;
  final String? voucherCode;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.isPaid,
    this.voucherCode,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'address': address,
    'paymentMethod': paymentMethod,
    'items': items,
    'subtotal': subtotal,
    'shippingFee': shippingFee,
    'discountAmount': discountAmount,
    'totalAmount': totalAmount,
    'status': status,
    'isPaid': isPaid,
    'voucherCode': voucherCode,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      address: map['address'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'waiting_confirm',
      isPaid: map['isPaid'] ?? false,
      voucherCode: map['voucherCode'],
    );
  }
}