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
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    // Logic tải lại giỏ hàng (giữ nguyên như cũ)
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cartProvider.fetchCartItems();
      });
    }
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
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

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();

    _selectedItems.retainWhere((id) => cartProvider.items.containsKey(id));

    double selectedTotal = 0.0;
    for (var itemId in _selectedItems) {
      if (cartProvider.items.containsKey(itemId)) {
        final cartItem = cartProvider.items[itemId]!;
        final product = productProvider.getProductById(cartItem.productId);
        if (product != null) {
          selectedTotal += product.basePrice * cartItem.quantity;
        }
      }
    }

    final allIds = cartProvider.items.keys.toList();
    final bool isAllSelected = allIds.isNotEmpty && _selectedItems.length == allIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: Text('Giỏ hàng (${cartProvider.totalItems})'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _selectAll(!isAllSelected, allIds),
            child: Text(
              isAllSelected ? "Bỏ chọn" : "Tất cả",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          if (_selectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _showDeleteSelectedDialog(context, cartProvider),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (cartProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (cartProvider.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: cartProvider.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
      bottomNavigationBar: cartProvider.items.isNotEmpty
          ? _buildCheckoutSection(context, selectedTotal)
          : null,
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemModel item, ProductModel product, {required bool isSelected}) {
    String options = "Size ${item.size}";
    if (item.sugarLevel?.isNotEmpty == true) options += ", ${item.sugarLevel}";
    if (item.iceLevel?.isNotEmpty == true) options += ", ${item.iceLevel}";
    if (item.toppings?.isNotEmpty == true) {
      options += "\nTopping: ${item.toppings!.join(', ')}";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      surfaceTintColor: Colors.white,
      child: InkWell(
        onTap: () => _toggleSelection(item.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 30,
                height: 30,
                child: Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (val) => _toggleSelection(item.id),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 30),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(options, style: const TextStyle(color: AppColors.textGrey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatCurrency(product.basePrice * item.quantity), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                        // GỌI WIDGET NHẬP LIỆU TRỰC TIẾP Ở ĐÂY
                        _QuantityInput(item: item),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, double selectedTotal) {
    bool hasSelection = _selectedItems.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tổng thanh toán:', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                  Text(formatCurrency(selectedTotal), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: hasSelection ? () async {
                //Truyền ds ID đã chọn sang CheckoutScreen
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CheckoutScreen(selectedCartItemIds: _selectedItems.toList())
                    )
                );

              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(0, 48),
              ),
              child: Text('Mua hàng (${_selectedItems.length})', style: const TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteSelectedDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa mục đã chọn'),
        content: Text('Xóa ${_selectedItems.length} sản phẩm?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              cartProvider.removeMultipleItems(_selectedItems.toList());
              setState(() => _selectedItems.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 100, color: AppColors.textLight.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('Giỏ hàng trống', style: TextStyle(color: AppColors.textGrey, fontSize: 18)),
        ],
      ),
    );
  }
}

// === WIDGET MỚI: NHẬP SỐ LƯỢNG TRỰC TIẾP ===
// Tách ra thành StatefulWidget riêng để quản lý TextField không bị mất focus khi rebuild
class _QuantityInput extends StatefulWidget {
  final CartItemModel item;

  const _QuantityInput({required this.item});

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Khởi tạo text bằng số lượng hiện tại
    _controller = TextEditingController(text: widget.item.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _QuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu số lượng từ Provider (widget.item.quantity) khác với số đang hiện trên ô nhập
    if (widget.item.quantity.toString() != _controller.text) {
      setState(() {
        _controller.text = widget.item.quantity.toString();
        // Giữ con trỏ ở cuối văn bản
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitValue(CartProvider provider) {
    final newQty = int.tryParse(_controller.text);
    if (newQty != null && newQty > 0) {
      provider.updateQuantity(widget.item.id, newQty);
    } else {
      // Nếu nhập sai (số 0 hoặc chữ), reset về số cũ
      _controller.text = widget.item.quantity.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút Trừ
          InkWell(
            onTap: () {
              if (widget.item.quantity > 1) {
                cartProvider.updateQuantity(widget.item.id, widget.item.quantity - 1);
              } else {
                _showDeleteDialog(context, cartProvider);
              }
            },
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.remove, size: 14)),
          ),

          // Ô Nhập Liệu Trực Tiếp
          SizedBox(
            width: 35, // Độ rộng vừa đủ cho 2-3 chữ số
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none, // Bỏ viền của TextField
              ),
              // Khi người dùng ấn Enter/Done trên bàn phím
              onSubmitted: (_) => _submitValue(cartProvider),
              // Khi người dùng bấm ra ngoài (mất focus) cũng tự lưu
              onTapOutside: (_) {
                _submitValue(cartProvider);
                FocusScope.of(context).unfocus();
              },
            ),
          ),

          // Nút Cộng
          InkWell(
            onTap: () => cartProvider.updateQuantity(widget.item.id, widget.item.quantity + 1),
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.add, size: 14, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: const Text('Bạn có muốn xóa sản phẩm này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              provider.removeItem(widget.item.id);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}