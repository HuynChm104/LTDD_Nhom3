import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Thêm dòng này để check Web
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/sqlite/db_helper.dart';

class ProductProvider extends ChangeNotifier {
  Map<String, ProductModel> _products = {};
  StreamSubscription? _productSubscription;
  bool _isLoading = true;

  List<ProductModel> get allProducts => _products.values.toList();
  bool get isLoading => _isLoading;

  ProductModel? getProductById(String id) {
    return _products[id];
  }

  ProductProvider() {
    _initData();
  }

  Future<void> _initData() async {
    // 1. KIỂM TRA NỀN TẢNG: Nếu không phải Web thì mới lấy dữ liệu từ SQLite
    if (!kIsWeb) {
      final localProducts = await DBHelper.getProducts(); // Gọi static method
      if (localProducts.isNotEmpty) {
        _products = {for (var p in localProducts) p.id: p};
        _isLoading = false;
        notifyListeners();
        print("Dữ liệu được tải từ SQLite (Mobile Offline)");
      }
    } else {
      print("Đang chạy trên Web: Bỏ qua SQLite, đợi dữ liệu từ Firebase");
    }

    // 2. Lắng nghe Stream từ Firebase (Hoạt động trên cả Web và Mobile)
    _productSubscription = ProductService.getAllProducts().listen((products) async {
      // Cập nhật bộ nhớ RAM (Map _products)
      _products = {for (var p in products) p.id: p};

      // 3. ĐỒNG BỘ: Chỉ lưu vào SQLite nếu đang chạy trên thiết bị di động
      if (!kIsWeb) {
        await DBHelper.insertProducts(products);
        print("Đã đồng bộ dữ liệu Firebase vào SQLite");
      }

      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint("Lỗi khi lắng nghe ProductService: $error");
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