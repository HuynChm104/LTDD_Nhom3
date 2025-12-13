// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Sử dụng icon Outlined để giao diện hiện đại hơn
  static const List<Map<String, dynamic>> _items = [
    {"icon": Icons.home_outlined, "label": "Trang chủ"},
    {"icon": Icons.local_offer_outlined, "label": "Ưu đãi"},
    {"icon": Icons.shopping_cart_outlined, "label": "Giỏ hàng"},
    {"icon": Icons.person_outline, "label": "Tài khoản"},
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy theme ra để sử dụng các style text
    final theme = Theme.of(context);

    // Bọc trong SafeArea để tránh các phần notch, dynamic island...
    return SafeArea(
      bottom: true, // Chỉ áp dụng SafeArea cho phần dưới
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 4), // Thêm padding để thoáng hơn
        decoration: BoxDecoration(
          // SỬA #1: Dùng màu nền surface từ constants
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              // SỬA #2: Dùng màu chủ đạo cho đổ bóng
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          // SỬA #3: Cập nhật màu sắc cho các item
          selectedItemColor: AppColors.primary,      // Màu chủ đạo khi chọn
          unselectedItemColor: AppColors.textGrey,    // Màu xám trung bình khi không chọn
          backgroundColor: Colors.transparent,        // Luôn trong suốt
          elevation: 0,
          type: BottomNavigationBarType.fixed,        // Luôn hiển thị label

          // Sử dụng style từ theme để nhất quán
          selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: theme.textTheme.bodySmall,

          items: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = currentIndex == index;

            return BottomNavigationBarItem(
              // SỬA #4: Thiết kế lại icon với logic màu mới
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  // Nền xanh nhạt khi được chọn
                  color: isSelected ? AppColors.primaryLight.withOpacity(0.7) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  item["icon"] as IconData,
                  size: 26,
                  // Màu icon sẽ được quản lý bởi `selectedItemColor` và `unselectedItemColor`
                ),
              ),
              label: item["label"] as String,
            );
          }).toList(),
          onTap: onTap,
        ),
      ),
    );
  }
}
