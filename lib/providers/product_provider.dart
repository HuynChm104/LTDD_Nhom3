// lib/providers/product_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  // Dùng Map để truy cập sản phẩm bằng ID nhanh hơn O(1)
  Map<String, ProductModel> _products = {};
  StreamSubscription? _productSubscription;
  bool _isLoading = true;

  List<ProductModel> get allProducts => _products.values.toList();
  bool get isLoading => _isLoading;

  // Hàm quan trọng để CartProvider và các màn hình khác có thể lấy thông tin sản phẩm
  ProductModel? getProductById(String id) {
    return _products[id];
  }

  ProductProvider() {
    // Lắng nghe mọi thay đổi từ stream của ProductService
    _productSubscription = ProductService.getAllProducts().listen((products) {
      // Chuyển List thành Map
      _products = {for (var p in products) p.id: p};
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Lỗi khi lắng nghe ProductService: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Hủy lắng nghe khi Provider bị dispose
  @override
  void dispose() {
    _productSubscription?.cancel();
    super.dispose();
  }
}
