// file: lib/utils/constants.dart (hoặc tương đương)
import 'package:flutter/material.dart';

class AppColors {
  // Tông màu xanh dương mới
  static const Color primary = Color(0xFFC0E0FF); // Xanh nhạt, nền/viền nhẹ
  static const Color primaryDark = Color(0xFF1E3A8A); // Xanh đậm, cho các yếu tố chính
  static const Color secondary = Color(0xFF60A5FA); // Xanh trung bình, có thể dùng cho nhấn mạnh

  // Các màu khác giữ lại hoặc điều chỉnh để phù hợp
  static const Color buttonDark = primaryDark; // Dùng màu xanh đậm cho nút và icon nổi bật
  static const Color textLight = Color(0xFF757575); // Màu xám nhẹ cho chữ không được chọn
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color error = Colors.red;
}