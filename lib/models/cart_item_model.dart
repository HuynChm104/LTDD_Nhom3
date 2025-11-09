class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final String size;
  final List<String>? toppings;   // topping optional
  final String? sugarLevel;       // sugar optional
  final String? iceLevel;         // ice optional

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.size,
    this.toppings,
    this.sugarLevel,
    this.iceLevel,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      quantity: json['quantity'] ?? '',
      size: json['size'] ?? '',
      toppings: json['toppings'] != null ? List<String>.from(json['toppings']) : null,
      sugarLevel: json['sugarLevel'] ?? '',
      iceLevel: json['iceLevel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'size': size,
      'toppings': toppings,
      'sugarLevel': sugarLevel,
      'iceLevel': iceLevel,
    };
  }
}
