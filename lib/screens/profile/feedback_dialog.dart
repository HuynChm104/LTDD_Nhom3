import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore
import 'package:firebase_auth/firebase_auth.dart';     // Thư viện Auth
import 'package:bongbieng_app/utils/constants.dart';   // Import màu AppColors

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false; // Biến để hiện vòng quay loading

  // --- HÀM GỬI PHẢN HỒI LÊN FIREBASE ---
  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // Không gửi nếu rỗng

    setState(() => _isSending = true); // Bắt đầu xoay loading

    try {
      // 1. Lấy thông tin người dùng hiện tại
      final user = FirebaseAuth.instance.currentUser;

      // 2. Gửi dữ liệu lên Firestore (Bảng 'feedbacks')
      // Nếu bảng chưa có, nó sẽ tự tạo.
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'content': text, // Nội dung người dùng nhập
        'userId': user?.uid ?? 'guest', // ID người dùng (nếu chưa đăng nhập thì là guest)
        'userEmail': user?.email ?? 'Không có email', // Email để liên hệ lại
        'createdAt': FieldValue.serverTimestamp(), // Thời gian server (chính xác)
        'status': 'new', // Trạng thái mặc định
        'device': 'App Mobile', // Nguồn gửi
      });

      // Giả lập trễ 1 chút cho người dùng kịp nhìn thấy loading (Trải nghiệm tốt hơn)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // 3. Đóng dialog và báo thành công
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cảm ơn bạn! Ý kiến đã được ghi nhận."),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 4. Xử lý lỗi nếu có
      print("Lỗi gửi phản hồi: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: Không thể gửi phản hồi lúc này."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      // Dù thành công hay thất bại cũng tắt loading
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.feedback_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Text("Gửi phản hồi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ý kiến của bạn giúp Bông Biêng phục vụ tốt hơn.",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _controller,
            maxLines: 5, // Cho nhập 5 dòng
            decoration: InputDecoration(
              hintText: "Nhập nội dung góp ý...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
      actions: [
        // Nút Hủy
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
        ),

        // Nút Gửi
        ElevatedButton(
          onPressed: _isSending ? null : _handleSend,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: _isSending
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Text("Gửi đi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}