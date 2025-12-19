import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderItemsSection extends StatelessWidget {
  final List<String> selectedIds; // Chỉ nhận các ID được chọn
  const OrderItemsSection({Key? key, required this.selectedIds}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();

    // Lọc ra các sản phẩm người dùng đã chọn ở giỏ hàng
    final selectedItems = cartProvider.items.values
        .where((item) => selectedIds.contains(item.id))
        .toList();

    return _BaseSection(
      title: "Món đã chọn (${selectedItems.length})",
      child: Column(
        children: selectedItems.map((item) {
          final product = productProvider.getProductById(item.productId);
          if (product == null) return const SizedBox.shrink();

          // Xây dựng chuỗi thông tin chi tiết (Đường, Đá, Topping)
          List<String> details = [];
          if (item.size.isNotEmpty) details.add("Size: ${item.size}");
          if (item.sugarLevel?.isNotEmpty == true) details.add(item.sugarLevel!);
          if (item.iceLevel?.isNotEmpty == true) details.add(item.iceLevel!);

          String toppingText = "";
          if (item.toppings?.isNotEmpty == true) {
            toppingText = "Topping: ${item.toppings!.join(', ')}";
          }

          final price = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
              .format(product.basePrice * item.quantity);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ẢNH SẢN PHẨM
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                  ),
                ),
                const SizedBox(width: 12),
                // 2. THÔNG TIN CHI TIẾT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
                      const SizedBox(height: 2),
                      Text(details.join(" | "),
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                      if (toppingText.isNotEmpty)
                        Text(toppingText,
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 11, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 4),

                      // Hiển thị số lượng nhỏ bên dưới
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text("Số lượng: ${item.quantity}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 10)),
                      ),
                    ],
                  ),
                ),

                // 3. GIÁ TIỀN
                Text(price, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BaseSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _BaseSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}