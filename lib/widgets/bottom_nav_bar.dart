// lib/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
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
    {"icon": Icons.home_outlined, "label": "Trang chủ"},
    {"icon": Icons.local_offer_outlined, "label": "Ưu đãi"},
    {"icon": Icons.shopping_cart_outlined, "label": "Giỏ hàng"}, // Index là 2
    {"icon": Icons.person_outline, "label": "Tài khoản"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: theme.textTheme.bodySmall,

          items: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = currentIndex == index;

            // Tạo widget icon cơ bản
            Widget iconWidget = AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight.withOpacity(0.7) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                item["icon"] as IconData,
                size: 26,
              ),
            );

            // Nếu là icon Giỏ hàng (index 2), bọc thêm Badge
            if (index == 2) {
              return BottomNavigationBarItem(
                icon: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        iconWidget,
                        if (cart.totalItems > 0) // Chỉ hiện khi có >= 1 loại sp
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red, // Màu đỏ nổi bật
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cart.totalItems}', // Hiển thị số loại sp
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                label: item["label"] as String,
              );
            }

            return BottomNavigationBarItem(
              icon: iconWidget,
              label: item["label"] as String,
            );
          }).toList(),
          onTap: onTap,
        ),
      ),
    );
  }
}
