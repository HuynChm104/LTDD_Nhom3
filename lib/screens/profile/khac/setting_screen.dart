// lib/screens/profile/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bongbieng_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../providers/auth_provider.dart';
import '../../auth/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _receiveNotification = true;
  final User? user = FirebaseAuth.instance.currentUser;

  // --- HÀM 1: GỬI EMAIL ĐỔI PASS ---
  Future<void> _resetPassword(BuildContext context) async {
    if (user?.email == null) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi email đổi mật khẩu!"), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi gửi email"), backgroundColor: AppColors.error),
      );
    }
  }

  // --- HÀM 2: XÓA TÀI KHOẢN ---
  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa tài khoản?"),
        content: const Text("Hành động này không thể hoàn tác. Mọi dữ liệu sẽ bị mất."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await user?.delete();
        if (context.mounted) {
          Provider.of<AuthProvider>(context, listen: false).signOut();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cần đăng nhập lại để xóa tài khoản."), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  // --- HÀM 3: DIALOG GIỚI THIỆU ---
  void _showCustomAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_drink, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bông Biêng", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Version 1.0.0", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ứng dụng đặt đồ uống Bông Biêng."),
            SizedBox(height: 10),
            Text("Phát triển bởi Nhóm 3 - Lớp Lập trình thiết bị di động.",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng", style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Cài đặt"),
        backgroundColor: AppColors.primaryLight,
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- NHÓM 1: THANH TOÁN ---
          _buildSectionTitle("Thanh toán"),
          _buildSettingsTile(
            icon: Icons.credit_card,
            title: "Phương thức thanh toán",
            subtitle: "Quản lý thẻ ngân hàng, ví điện tử",
            onTap: () {
              // Mock action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tính năng đang được phát triển")),
              );
            },
          ),

          const SizedBox(height: 20),

          // --- NHÓM 2: CÀI ĐẶT ỨNG DỤNG ---
          _buildSectionTitle("Cài đặt ứng dụng"),
          _buildSwitchTile(
            title: "Nhận thông báo",
            value: _receiveNotification,
            onChanged: (val) => setState(() => _receiveNotification = val),
          ),

          const SizedBox(height: 20),

          // --- NHÓM 3: BẢO MẬT ---
          _buildSectionTitle("Bảo mật"),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: "Đổi mật khẩu",
            onTap: () => _resetPassword(context),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: "Yêu cầu xóa tài khoản",
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _deleteAccount(context),
          ),

          const SizedBox(height: 20),

          // --- NHÓM 4: THÔNG TIN ---
          _buildSectionTitle("Thông tin"),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "Về Bông Biêng App",
            onTap: _showCustomAboutDialog,
          ),

          const SizedBox(height: 30),
          Center(
            child: Text(
              "Phiên bản 1.0.0 (Build 2025)",
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color textColor = Colors.black,
    Color iconColor = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: SwitchListTile(
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: const Text("Nhận thông báo", style: TextStyle(fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
          child: Icon(value ? Icons.notifications_active : Icons.notifications_off, color: Colors.grey[600], size: 20),
        ),
      ),
    );
  }
}