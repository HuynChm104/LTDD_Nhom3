import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/db_helper.dart'; // Import file DBHelper bạn vừa tạo

class ProductProvider extends ChangeNotifier {
  Map<String, ProductModel> _products = {};
  StreamSubscription? _productSubscription;
  bool _isLoading = true;

  // Khởi tạo DBHelper
  final DBHelper _dbHelper = DBHelper();

  List<ProductModel> get allProducts => _products.values.toList();
  bool get isLoading => _isLoading;

  ProductModel? getProductById(String id) {
    return _products[id];
  }

  ProductProvider() {
    _initData();
  }

  Future<void> _initData() async {
    // 1. Ưu tiên lấy dữ liệu từ SQLite trước để UI hiện lên ngay lập tức (Offline/Cache)
    final localProducts = await _dbHelper.getProducts();
    if (localProducts.isNotEmpty) {
      _products = {for (var p in localProducts) p.id: p};
      _isLoading = false;
      notifyListeners();
    }

    // 2. Sau đó mới lắng nghe Stream từ Firebase để cập nhật dữ liệu mới nhất (Online)
    _productSubscription = ProductService.getAllProducts().listen((products) async {
      // Chuyển List thành Map
      _products = {for (var p in products) p.id: p};

      // 3. ĐỒNG BỘ: Lưu dữ liệu mới nhất từ Firebase vào SQLite để dùng cho lần sau
      await _dbHelper.insertProducts(products);

      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Lỗi khi lắng nghe ProductService: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    super.dispose();
  }
}