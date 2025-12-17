// lib/screens/profile/privacy_policy_dialog.dart

import 'package:flutter/material.dart';
import 'package:bongbieng_app/utils/constants.dart'; // Import để lấy AppColors

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface, // Hoặc Colors.white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          const Text("Chính sách bảo mật", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView( // Cho phép cuộn nếu nội dung dài
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection("1. Thu thập thông tin",
                  "Chúng tôi thu thập thông tin cá nhân cơ bản (Tên, SĐT, Email, Ảnh đại diện) để phục vụ việc định danh và giao hàng."),
              _buildSection("2. Sử dụng thông tin",
                  "Thông tin của bạn được sử dụng để xử lý đơn hàng, tích điểm thành viên và gửi các thông báo quan trọng."),
              _buildSection("3. Bảo mật dữ liệu",
                  "Chúng tôi cam kết không chia sẻ thông tin của bạn cho bên thứ ba, ngoại trừ các đối tác vận chuyển để giao hàng."),
              _buildSection("4. Quyền lợi người dùng",
                  "Bạn có quyền yêu cầu chỉnh sửa hoặc xóa dữ liệu cá nhân của mình khỏi hệ thống bất cứ lúc nào."),
              const SizedBox(height: 10),
              const Text(
                "Cập nhật lần cuối: 12/2025",
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Đóng dialog
          child: const Text("Đã hiểu", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // Widget con để vẽ từng đoạn văn
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }
}