import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final String image, name, price;
  final VoidCallback onTap, onCart;

  const ProductCard({super.key, required this.image, required this.name, required this.price, required this.onTap, required this.onCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Card trong suốt, hòa vào background.
        color: AppColors.white,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh tỷ lệ 1.4/1 (rộng hơn chiều cao) bo tròn 4 góc. Giảm tỷ lệ này để fix overflow.
            AspectRatio(
              aspectRatio: 1.4 / 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary, // Xanh nhạt cho placeholder
                    child: const Icon(Icons.image, size: 50, color: AppColors.primaryDark),
                  ),
                ),
              ),
            ),
            // Phần thông tin sản phẩm
            // Giảm padding và khoảng cách để phần thông tin gọn lại, thu nhỏ tổng thể card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // Giảm padding dọc
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm - Font 15, rất đậm
                  Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 5), // Giảm khoảng cách
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Giá tiền - Font 17, rất đậm, đơn vị "đ"
                      Text(
                          "$price đ",
                          style: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          )
                      ),
                      // Nút "+" vuông bo tròn
                      GestureDetector(
                        onTap: onCart,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, size: 18, color: AppColors.white),
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