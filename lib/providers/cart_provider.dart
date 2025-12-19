// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:uuid/uuid.dart'; // Không cần dùng Uuid nữa
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'product_provider.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ProductProvider? _productProvider;

  Map<String, CartItemModel> _items = {};
  bool _isLoading = false;

  Map<String, CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  void update(ProductProvider productProvider) {
    _productProvider = productProvider;
  }

  double get totalPrice {
    if (_productProvider == null) return 0.0;
    double total = 0.0;
    _items.forEach((key, cartItem) {
      final product = _productProvider!.getProductById(cartItem.productId);
      if (product != null) {
        total += product.basePrice * cartItem.quantity;
      }
    });
    return total;
  }

  int get totalItems => _items.length;

  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCartItems() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).collection('cart').get();
      _items = {for (var doc in snapshot.docs) doc.id: CartItemModel.fromJson(doc.data())};
    } catch (e) {
      print("Lỗi khi lấy giỏ hàng từ Firestore: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearCartOnSignOut() {
    _items.clear();
    notifyListeners();
  }

  // === SỬA LẠI TOÀN BỘ LOGIC HÀM NÀY ĐỂ CỘNG DỒN SẢN PHẨM ===
  Future<void> addItem({
    required ProductModel product,
    required int quantity,
    required String size,
    String? sugarLevel,
    String? iceLevel,
    Set<String>? toppings,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Tạo một ID tường minh dựa trên tất cả các lựa chọn.
    // Sắp xếp topping để đảm bảo thứ tự không ảnh hưởng đến ID.
    final sortedToppings = toppings?.toList()?..sort();
    final uniqueId = '${product.id}_${size}_${sugarLevel}_${iceLevel}_$sortedToppings';

    final cartCollection = _firestore.collection('users').doc(user.uid).collection('cart');

    try {
      final existingDoc = await cartCollection.doc(uniqueId).get();

      // 2. Kiểm tra xem item với uniqueId này đã tồn tại trong giỏ hàng trên Firestore chưa.
      if (existingDoc.exists) {
        // Nếu có, chỉ cần cập nhật lại số lượng.
        final newQuantity = existingDoc.data()!['quantity'] + quantity;
        await cartCollection.doc(uniqueId).update({'quantity': newQuantity});
      } else {
        // Nếu không có, tạo một CartItem mới.
        final newCartItem = CartItemModel(
          id: uniqueId,
          userId: user.uid,
          productId: product.id,
          quantity: quantity,
          size: size,
          toppings: sortedToppings,
          sugarLevel: sugarLevel,
          iceLevel: iceLevel,
        );
        await cartCollection.doc(uniqueId).set(newCartItem.toJson());
      }

      // 3. Sau khi thao tác với DB, tải lại toàn bộ giỏ hàng để đảm bảo UI đồng bộ 100%.
      await fetchCartItems();
    } catch (e) {
      print("Lỗi khi thêm/cập nhật giỏ hàng: $e");
    }
  }

  // CẬP NHẬT SỐ LƯỢNG
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
      return;
    }
    final user = _auth.currentUser;
    if (user == null) return;

    // Cập nhật trên UI trước để có phản hồi tức thì
    if (_items.containsKey(cartItemId)) {
      _items[cartItemId]!.quantity = newQuantity;
      notifyListeners();
    }

    // Sau đó cập nhật lên Firestore
    await _firestore.collection('users').doc(user.uid).collection('cart').doc(cartItemId).update({'quantity': newQuantity});
  }

  // XÓA 1 ITEM
  Future<void> removeItem(String cartItemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    _items.remove(cartItemId);
    notifyListeners();
    await _firestore.collection('users').doc(user.uid).collection('cart').doc(cartItemId).delete();
  }

  // XÓA NHIỀU ITEM CÙNG LÚC
// lib/providers/cart_provider.dart

  Future<void> removeMultipleItems(List<String> cartItemIds) async {
    final user = _auth.currentUser;
    if (user == null || cartItemIds.isEmpty) return;

    // 1. Cập nhật UI ngay lập tức
    for (var id in cartItemIds) {
      _items.remove(id);
    }
    notifyListeners(); // Cập nhật UI lần 1

    try {
      final cartCollection = _firestore.collection('users').doc(user.uid).collection('cart');
      WriteBatch batch = _firestore.batch();
      for (var id in cartItemIds) {
        batch.delete(cartCollection.doc(id));
      }
      await batch.commit();
      // Không cần fetch lại toàn bộ vì ta đã xóa thủ công ở trên
    } catch (e) {
      print("Lỗi khi xóa nhiều mục: $e");
      await fetchCartItems(); // Nếu lỗi thì đồng bộ lại từ server
    }
  }
  // XÓA TOÀN BỘ GIỎ HÀNG
  Future<void> clearCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _items.clear();
    notifyListeners();

    final cartCollection = _firestore.collection('users').doc(user.uid).collection('cart');
    final snapshot = await cartCollection.get();
    WriteBatch batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
