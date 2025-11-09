// file: lib/widgets/bottom_nav_bar.dart (hoặc tương đương)
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

  static const List<Map<String, dynamic>> _items = [
    {"icon": Icons.menu, "label": "Menu"},
    {"icon": Icons.local_offer, "label": "Voucher"},
    {"icon": Icons.shopping_cart, "label": "Cart"},
    {"icon": Icons.person, "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, // Màu nền trắng
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), // Bo tròn góc trên
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonDark.withOpacity(0.1), // Shadow màu xanh đậm nhẹ
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppColors.buttonDark, // Màu xanh đậm khi chọn
        unselectedItemColor: AppColors.textLight, // Màu xám nhẹ khi không chọn
        backgroundColor: Colors.transparent, // Nền trong suốt để container bên ngoài quản lý màu
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: _items.asMap().entries.map((e) {
          final item = e.value;
          final isSelected = currentIndex == e.key;
          return BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // Thay đổi: Màu nền xanh nhạt khi chọn
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item["icon"] as IconData,
                size: 24,
                // Thay đổi: Icon màu xanh đậm khi chọn, xám nhẹ khi không chọn
                color: isSelected ? AppColors.buttonDark : AppColors.textLight,
              ),
            ),
            label: item["label"] as String,
          );
        }).toList(),
        onTap: onTap,
      ),
    );
  }
}