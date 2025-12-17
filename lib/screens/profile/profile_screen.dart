// lib/screens/profile/profile_screen.dart

import 'package:bongbieng_app/models/user_model.dart'; // SỬA: Import UserModel
import 'package:bongbieng_app/screens/profile/edit_profile_screen.dart';
import 'package:bongbieng_app/providers/auth_provider.dart';
import 'package:bongbieng_app/screens/profile/setting_screen.dart';
import 'package:bongbieng_app/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bongbieng_app/screens/profile/privacy_policy_dialog.dart';
import 'package:bongbieng_app/screens/profile/loyalty_screen.dart';
import 'package:bongbieng_app/screens/profile/feedback_dialog.dart';

import '../../providers/cart_provider.dart';
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: AppColors.textGrey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
              ),
              child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // Đăng xuất và xóa giỏ hàng
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                cartProvider.clearCartOnSignOut();
                await authProvider.signOut();
                // Đổi sang màn hình đăng nhập
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                        (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang xử lý...')),
    );

    final success = await authProvider.uploadImage();

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Cập nhật ảnh đại diện thành công!'
              : (authProvider.errorMessage ?? 'Tải ảnh lên thất bại.')),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildUserHeader(
              context,
              user, // Truyền UserModel
              onCameraTap: () => _changeProfilePicture(context),
            ),
            const SizedBox(height: 32),
            _buildSection(
              context: context,
              title: "Tôi",
              items: [
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: "Chỉnh sửa hồ sơ",
                  onTap: () {
                    // SỬA: Điều hướng và truyền UserModel hiện tại sang
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(currentUser: user)),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  label: "Hạng Thành viên: Mới",
                  subtitle: "Sắp lên hạng Bạc",
                  leading: Image.asset(
                    'assets/images/hoa.jpg',
                    width: 28,
                    height: 28,
                    errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 28, color: Colors.amber),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoyaltyScreen()),
                    );
                  }
                ),
                _MenuItem(
                  icon: Icons.airplane_ticket_outlined,
                  label: "Voucher của tôi",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chức năng này sẽ được xử lý ở Bottom Navigation Bar.')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context: context,
              title: "Khác",
              items: [
                _MenuItem(
                    icon: Icons.settings_outlined,
                    label: "Cài đặt",
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    }
                ),
                _MenuItem(
                    icon: Icons.shield_outlined,
                    label: "Chính sách bảo mật",
                     onTap: () {
                      // Gọi hàm hiển thị dialog
                       showDialog(context: context,
                                  builder: (context) => const PrivacyPolicyDialog(),
                       );
                     }
                ),
                _MenuItem(
                    icon: Icons.feedback_outlined,
                    label: "Gửi phản hồi",
                    onTap: (){
                      showDialog(context: context, builder: (context) => const FeedbackDialog(),
                      );
                    }
                ),
                _MenuItem(icon: Icons.history_outlined, label: "Lịch sử điểm"),
                _MenuItem(
                  icon: Icons.logout,
                  label: "Đăng xuất",
                  isDestructive: true,
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "Phiên bản 1.0.0",
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }

  // SỬA: Hàm này nhận UserModel
  Widget _buildUserHeader(BuildContext context, UserModel user, {required VoidCallback onCameraTap}) {
    final theme = Theme.of(context);
    // SỬA: Ưu tiên phone từ UserModel, nếu không có thì mới đến email
    final String contactInfo = user.phone.isNotEmpty ? user.phone : user.email;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: CircleAvatar(
                key: ValueKey(user.avatar),
                radius: 48,
                backgroundColor: AppColors.surface,
                // SỬA: Dùng trường 'avatar' từ UserModel
                backgroundImage: CachedNetworkImageProvider(user.avatar),
                child: user.avatar.isEmpty
                    ? Icon(Icons.person, size: 60, color: AppColors.primary.withOpacity(0.8))
                    : null,
              ),
            ),
            GestureDetector(
              onTap: onCameraTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // SỬA: Dùng trường 'name' từ UserModel
        Text(
          user.name.isNotEmpty ? user.name : "Người dùng mới",
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        if (contactInfo.isNotEmpty)
          Text(
            contactInfo,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
          ),
      ],
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required List<_MenuItem> items}) {
    // ... (Không thay đổi)
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (_, index) => _buildMenuItem(context, items[index]),
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.background),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final theme = Theme.of(context);
    final color = item.isDestructive ? AppColors.error : AppColors.textDark;
    return ListTile(
      onTap: item.onTap,
      leading: Container(
        width: 40, // Cố định chiều rộng
        height: 40, // Cố định chiều cao
        padding: const EdgeInsets.all(8), // Padding bên trong
        decoration: BoxDecoration(
          // Nếu là item có ảnh riêng thì dùng nền trắng, còn ko giữ màu mặc định
          color: (item.leading != null)
              ? Colors.white.withValues(alpha: 0.1)
              : (item.isDestructive ? AppColors.error : AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        // Logic hiển thị: Nếu có ảnh riêng (leading) thì hiện ảnh, ko thì hiện Icon
        child: item.leading ?? Icon(
            item.icon,
            color: item.isDestructive ? AppColors.error : AppColors.primary,
            size: 22
        ),
      ),
      title: Text(item.label, style: theme.textTheme.bodyLarge?.copyWith(color: color, fontWeight: FontWeight.w500)),
      subtitle: item.subtitle != null
          ? Text(item.subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textGrey))
          : null,
      trailing: item.isDestructive ? null : const Icon(Icons.chevron_right, color: AppColors.textGrey, size: 20),
    );
  }
}

class _MenuItem {
  // ... (Không thay đổi)
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool isDestructive;

  _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.leading,
    this.onTap,
    this.isDestructive = false,
  });
}
