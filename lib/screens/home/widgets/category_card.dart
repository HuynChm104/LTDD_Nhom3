// lib/screens/home/widgets/category_card.dart
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy màu từ file constants mới
    const Color selectedColor = AppColors.primary;
    const Color unselectedColor = AppColors.primary;
    const Color selectedBackgroundColor = AppColors.primary;
    const Color unselectedBackgroundColor = AppColors.surface; // Nền trắng/surface
    const Color selectedContentColor = AppColors.white; // Chữ và icon khi được chọn

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Tăng padding dọc một chút
        decoration: BoxDecoration(
          //Màu nền dựa trên trạng thái
          color: isSelected ? selectedBackgroundColor : unselectedBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          //Viền màu chủ đạo khi chưa chọn
          border: Border.all(
            color: selectedColor,
            width: isSelected ? 2 : 1.5, // Viền dày hơn một chút khi được chọn
          ),
          boxShadow: [
            // Giữ lại hiệu ứng đổ bóng nhẹ
            BoxShadow(
              color: AppColors.primary.withOpacity(isSelected ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              //Màu icon
              color: isSelected ? selectedContentColor : unselectedColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                //Màu chữ
                color: isSelected ? selectedContentColor : unselectedColor,
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
