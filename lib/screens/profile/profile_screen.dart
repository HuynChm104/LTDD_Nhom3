// lib/screens/profile/profile_screen.dart
import 'package:bongbieng_app/providers/auth_provider.dart';
import 'package:bongbieng_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await authProvider.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đã đăng xuất thành công"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout, color: AppColors.black, size: 24),
            tooltip: "Đăng xuất",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // === 1. AVATAR + TÊN + SĐT – CĂN GIỮA, TRÊN CÙNG ===
            _buildUserHeader(user),

            const SizedBox(height: 24),

            // === 2. SECTION "TÔI" – CHỈ CHỨA 2 MỤC ===
            _buildSection(
              title: "Tôi",
              items: [
                _MenuItem(
                  icon: Icons.edit,
                  label: "Chỉnh sửa hồ sơ",
                  onTap: () {
                    // Navigator.push(...) → Trang chỉnh sửa hồ sơ
                  },
                ),
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
                  onTap: () {
                    // Navigator.push(...) → Trang chi tiết hạng
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSection(
              title: "Túi đồ",
              items: [
                _MenuItem(icon: Icons.airplane_ticket, label: "Voucher của tôi"),
                _MenuItem(icon: Icons.card_giftcard, label: "Giải thưởng Mini Game"),
              ],
            ),
            const SizedBox(height: 16),

            _buildSection(
              title: "Khác",
              items: [
                _MenuItem(icon: Icons.settings, label: "Cài đặt"),
                _MenuItem(icon: Icons.star, label: "Tích bông"),
                _MenuItem(icon: Icons.policy, label: "Chính sách bảo mật"),
                _MenuItem(icon: Icons.feedback, label: "Phản hồi/Góp ý"),
                _MenuItem(icon: Icons.history, label: "Lịch sử tích bông"),
                _MenuItem(icon: Icons.lock, label: "Đổi mật khẩu"),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // HEADER: AVATAR + TÊN + SĐT – CĂN GIỮA
  Widget _buildUserHeader(user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: user?.photoURL != null
                  ? CircleAvatar(
                      radius: 47,
                      backgroundImage: NetworkImage(user!.photoURL!),
                    )
                  : CircleAvatar(
                      radius: 47,
                      backgroundColor: Colors.grey[300],
                      child: Text(
                        user?.displayName?.isNotEmpty == true
                            ? user!.displayName![0].toUpperCase()
                            : user?.email?.isNotEmpty == true
                                ? user!.email![0].toUpperCase()
                                : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
        Text(
          user?.displayName ?? user?.email?.split('@')[0] ?? 'Người dùng',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
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
      leading: item.leading ?? Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: AppColors.black, size: 20),
      ),
      title: Text(
        item.label,
        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500),
      ),
      subtitle: item.subtitle != null
          ? Text(
        item.subtitle!,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      )
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