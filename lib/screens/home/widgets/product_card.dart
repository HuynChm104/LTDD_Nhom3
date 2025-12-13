// lib/screens/home/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final String image, name, price;
  final VoidCallback onTap, onCart;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.onTap,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy theme từ context để sử dụng các style đã được định nghĩa sẵn
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // SỬA #1: Thêm hiệu ứng nổi cho Card
        decoration: BoxDecoration(
          color: AppColors.surface, // Dùng màu nền từ constants
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    // SỬA #2: Sửa lại màu cho placeholder khi ảnh lỗi
                    color: AppColors.primaryLight, // Nền xanh nhạt
                    child: const Icon(
                      Icons.coffee_maker_outlined, // Icon phù hợp hơn
                      size: 50,
                      color: AppColors.primary, // Icon màu xanh đậm
                    ),
                  ),
                ),
              ),
            ),
            // Phần thông tin sản phẩm
            Padding(
              padding: const EdgeInsets.all(12), // Padding đều các cạnh
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    name,
                    // SỬA #3: Sử dụng style từ Theme
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Giá tiền
                      Text(
                        "$price đ",
                        // SỬA #4: Sử dụng style từ Theme
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary, // Giá tiền dùng màu chủ đạo cho nổi bật
                        ),
                      ),
                      // Nút "+"
                      GestureDetector(
                        onTap: onCart,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            // SỬA #5: Dùng màu chủ đạo
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 20, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
