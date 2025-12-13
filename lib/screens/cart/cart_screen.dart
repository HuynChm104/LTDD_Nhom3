// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // State để quản lý chế độ chọn
  final Set<String> _selectedItems = {};
  bool _isSelectionMode = false;

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  // === CÁC HÀM QUẢN LÝ STATE CỦA CHẾ ĐỘ CHỌN ===
  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _toggleSelection(String cartItemId) {
    setState(() {
      if (_selectedItems.contains(cartItemId)) {
        _selectedItems.remove(cartItemId);
      } else {
        _selectedItems.add(cartItemId);
      }
    });
  }

  void _selectAll(bool select, List<String> allItemIds) {
    setState(() {
      if (select) {
        _selectedItems.addAll(allItemIds);
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });
  }

  // === BUILD WIDGET CHÍNH ===
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.read<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, cartProvider),
      body: Builder(
        builder: (context) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cartProvider.items.isEmpty) {
            if (_isSelectionMode) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _exitSelectionMode());
            }
            return _buildEmptyCart(context);
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  // Thêm padding dưới để item cuối không bị che
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (ctx, i) {
                    final cartItem = cartProvider.items.values.elementAt(i);
                    final product = productProvider.getProductById(cartItem.productId);
                    if (product == null) return const SizedBox.shrink();

                    return _buildCartItemCard(
                      context,
                      cartItem,
                      product,
                      isSelected: _selectedItems.contains(cartItem.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Chỉ hiển thị thanh checkout khi không ở chế độ chọn
      bottomNavigationBar: !_isSelectionMode && cartProvider.items.isNotEmpty
          ? _buildCheckoutSection(context, cartProvider.totalPrice)
          : null,
    );
  }

  // === APP BAR ĐỘNG ===
  AppBar _buildAppBar(BuildContext context, CartProvider cartProvider) {
    final allItemIds = cartProvider.items.keys.toList();
    final bool isAllSelected = _selectedItems.length == allItemIds.length && allItemIds.isNotEmpty;

    if (_isSelectionMode) {
      // AppBar ở chế độ chọn
      return AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
        title: Text('${_selectedItems.length} đã chọn'),
        actions: [
          TextButton(
            onPressed: () => _selectAll(!isAllSelected, allItemIds),
            child: Text(isAllSelected ? 'BỎ CHỌN' : 'CHỌN TẤT CẢ'),
          ),
          IconButton(
            tooltip: 'Xóa mục đã chọn',
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _selectedItems.isNotEmpty ? () => _showDeleteSelectedDialog(context, cartProvider) : null,
          ),
        ],
      );
    } else {
      // AppBar bình thường
      return AppBar(
        backgroundColor: AppColors.primaryLight,
        title: Text('Giỏ hàng (${cartProvider.totalItems})'),
        centerTitle: true,
        actions: [
          if (cartProvider.items.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'select') {
                  _enterSelectionMode();
                } else if (value == 'clear_all') {
                  _showClearCartDialog(context, cartProvider);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'select',
                  child: ListTile(
                    leading: Icon(Icons.check_box_outlined),
                    title: Text('Chọn sản phẩm'),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'clear_all',
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                    title: Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
        ],
      );
    }
  }

  // === CARD SẢN PHẨM TRONG GIỎ HÀNG ===
  Widget _buildCartItemCard(BuildContext context, CartItemModel item, ProductModel product, {required bool isSelected}) {
    String options = "Size ${item.size}";
    if (item.sugarLevel != null && item.sugarLevel!.isNotEmpty) options += ", ${item.sugarLevel}";
    if (item.iceLevel != null && item.iceLevel!.isNotEmpty) options += ", ${item.iceLevel}";
    if (item.toppings != null && item.toppings!.isNotEmpty) {
      options += "\nTopping: ${item.toppings!.join(', ')}";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) _toggleSelection(item.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox chỉ hiển thị ở chế độ chọn
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IgnorePointer(
                    child: Checkbox(value: isSelected, onChanged: (val) {}, activeColor: AppColors.primary),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.background),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined, size: 40),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 5),
                    Text(options, style: const TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(
                      formatCurrency(product.basePrice * item.quantity),
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                  ],
                ),
              ),
              const SizedBox(width: 5),
              // Cụm chỉnh sửa số lượng
              _buildQuantityControl(context, item),

            ],
          ),
        ),
      ),
    );
  }

  // === CỤM NÚT CHỈNH SỬA SỐ LƯỢNG ===
  Widget _buildQuantityControl(BuildContext context, CartItemModel item) {
    final cartProvider = context.read<CartProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nút tăng
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => cartProvider.updateQuantity(item.id, item.quantity + 1),
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            splashRadius: 18,
          ),
        ),
        // Số lượng có thể nhấn
        GestureDetector(
          onTap: () => _showQuantityInputDialog(context, cartProvider, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        // Nút giảm
        SizedBox(
          width: 36,
          height: 36,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              if (item.quantity > 1) {
                cartProvider.updateQuantity(item.id, item.quantity - 1);
              } else {
                _showDeleteItemDialog(context, cartProvider, item);
              }
            },
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.textGrey),
            splashRadius: 18,
          ),
        ),
      ],
    );
  }

  // === CÁC HỘP THOẠI DIALOG ===
  void _showQuantityInputDialog(BuildContext context, CartProvider cartProvider, CartItemModel item) {
    final TextEditingController controller = TextEditingController(text: item.quantity.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nhập số lượng'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Không được trống';
              final n = int.tryParse(value);
              if (n == null) return 'Phải là số';
              if (n <= 0) return 'Phải lớn hơn 0';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newQuantity = int.parse(controller.text);
                cartProvider.updateQuantity(item.id, newQuantity);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(BuildContext context, CartProvider cartProvider, CartItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              cartProvider.removeItem(item.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSelectedDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc chắn muốn xóa ${_selectedItems.length} mục đã chọn?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              cartProvider.removeMultipleItems(_selectedItems.toList());
              Navigator.of(ctx).pop();
              // Thoát chế độ chọn sau khi dialog đóng
              _exitSelectionMode();
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa toàn bộ sản phẩm trong giỏ hàng?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.of(ctx).pop();
            },
            child: const Text('Xóa tất cả', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // === CÁC WIDGET PHỤ ===
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('Giỏ hàng của bạn đang trống', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textGrey)),
          const SizedBox(height: 10),
          const Text('Cùng khám phá và chọn món ngon nhé!', style: TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, double totalPrice) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng cộng:', style: Theme.of(context).textTheme.titleLarge),
              Text(formatCurrency(totalPrice), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: totalPrice > 0
                  ? () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chuyển đến màn hình thanh toán...')));
              }
                  : null,
              child: const Text('Thanh toán'),
            ),
          )
        ],
      ),
    );
  }
}
