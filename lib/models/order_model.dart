import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String branchId;
  final List<CartItemModel> items;
  final double totalPrice;
  final DateTime orderTime;
  final String status;
  final String deliveryAddress;
  final String? note;  // note optional

  OrderModel({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.items,
    required this.totalPrice,
    required this.orderTime,
    required this.status,
    this.deliveryAddress = '',
    this.note,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      branchId: json['branchId'] ?? '',
      items: List<CartItemModel>.from(json['items'].map((item) => CartItemModel.fromJson(item))),
      totalPrice: json['totalPrice'] ?? 0.0,
      orderTime: DateTime.parse(json['orderTime']) ?? DateTime.now(),
      status: json['status'],
      deliveryAddress: json['deliveryAddress'] ?? '',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'branchId': branchId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'orderTime': orderTime.toIso8601String(),
      'status': status,
      'deliveryAddress': deliveryAddress,
      'note': note,
    };
  }
}
