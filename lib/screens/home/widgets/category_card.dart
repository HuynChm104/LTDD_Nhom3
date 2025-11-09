// file: lib/screens/home/widgets/category_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';

class CategoryCard extends StatelessWidget { // Đổi tên class
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Thiết kế theo hình bên phải: hình chữ nhật bo tròn với icon/label bên trong
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Thay đổi: Màu nền dựa vào trạng thái chọn
          color: isSelected ? AppColors.buttonDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          // Thay đổi: Viền màu xanh đậm khi chưa chọn
          border: Border.all(color: AppColors.buttonDark, width: isSelected ? 0 : 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Đảm bảo container không bị kéo giãn quá mức
          children: [
            Icon(
                icon,
                size: 20,
                // Màu icon
                color: isSelected ? AppColors.white : AppColors.buttonDark
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                // Màu chữ
                color: isSelected ? AppColors.white : AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}