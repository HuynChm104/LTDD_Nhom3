// lib/screens/profile/profile_screen.dart
import 'package:bongbieng_app/utils/constants.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        //title: const Text("Hồ sơ"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // === 1. AVATAR + TÊN + SĐT ===
            _buildUserHeader(),

            const SizedBox(height: 24),

            // === 2. SECTION "TÔI" ===
            _buildSection(
              title: "Tôi",
              items: [
                _MenuItem(icon: Icons.edit, label: "Chỉnh sửa hồ sơ"),
                _MenuItem(
                  icon: Icons.star,
                  label: "Hạng Thành viên Bạn mới",
                  subtitle: "10 bông nữa lên Bạc",
                  leading: Image.asset(
                    'assets/images/hoa.jpg',
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 28, color: Colors.amber),
                  ),
                ),
                _MenuItem(icon: Icons.airplane_ticket, label: "Voucher của tôi"),
                _MenuItem(icon: Icons.card_giftcard, label: "Giải thưởng Mini Game"),
              ],
            ),

            const SizedBox(height: 16),

            // === 3. SECTION "KHÁC" – ĐÃ THÊM "ĐĂNG XUẤT" VÀO ĐÂY ===
            _buildSection(
              title: "Khác",
              items: [
                _MenuItem(icon: Icons.settings, label: "Cài đặt"),
                _MenuItem(icon: Icons.star, label: "Tích bông"),
                _MenuItem(icon: Icons.policy, label: "Chính sách bảo mật"),
                _MenuItem(icon: Icons.feedback, label: "Phản hồi/Góp ý"),
                _MenuItem(icon: Icons.history, label: "Lịch sử tích bông"),
                _MenuItem(icon: Icons.lock, label: "Đổi mật khẩu"),
                // ĐĂNG XUẤT – NẰM CUỐI CÙNG, GIỐNG CÁC MỤC KHÁC
                _MenuItem(
                  icon: Icons.logout,
                  label: "Đăng xuất",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã đăng xuất thành công!")),
                    );
                    // TODO: Xử lý đăng xuất thật ở đây
                  },
                ),
              ],
            ),

            const SizedBox(height: 100), // Để scroll xuống thấy nút đăng xuất
          ],
        ),
      ),
    );
  }

  // HEADER: AVATAR + TÊN + SĐT
  Widget _buildUserHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 47,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 55, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Chmmm",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          "0842666121",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // SECTION CHUNG
  Widget _buildSection({required String title, required List<_MenuItem> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
            ),
          ),
          ...items.map((item) => _buildMenuItem(item)).toList(),
        ],
      ),
    );
  }

  // ITEM TRONG SECTION
  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      leading: item.leading ??
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AppColors.black, size: 20),
          ),
      title: Text(
        item.label,
        style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
      subtitle: item.subtitle != null
          ? Text(item.subtitle!, style: const TextStyle(fontSize: 13, color: Colors.grey))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: item.onTap ?? () {},
    );
  }
}

// MODEL ITEM
class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.leading,
    this.onTap,
  });
}