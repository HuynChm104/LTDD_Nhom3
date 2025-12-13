// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // === MÀU CHỦ ĐẠO (PRIMARY) ===
  // Màu chủ đạo, dùng cho các nút bấm chính, icon quan trọng, và các yếu tố cần nổi bật.
  static const Color primary = Color(0xFF1E3A8A); // Xanh đậm

  // === CÁC BIẾN THỂ VÀ MÀU PHỤ (SECONDARY) ===
  // Dùng cho các yếu tố nhấn mạnh, trạng thái hover, hoặc các thành phần phụ.
  static const Color secondary = Color(0xFF60A5FA); // Xanh trung bình

  // Dùng cho viền, nền của các container cần sự nhẹ nhàng.
  static const Color primaryLight = Color(0xFFC0E0FF); // Xanh nhạt

  // === MÀU NỀN (BACKGROUND & SURFACE) ===
  // Màu nền chính cho toàn bộ ứng dụng.
  static const Color background = Color(0xFFFFFFFF); // Giữ màu trắng hoặc đổi sang F5F5F5 nếu muốn

  // Màu cho các bề mặt như Card, Dialog, BottomSheet.
  static const Color surface = Color(0xFFFFFFFF);

  // === MÀU VĂN BẢN (TEXT) ===
  // Dùng cho tiêu đề, văn bản quan trọng.
  static const Color textDark = Color(0xFF1F2937); // Màu đen-xám đậm

  // Dùng cho các đoạn mô tả, văn bản phụ.
  static const Color textGrey = Color(0xFF6B7280); // Màu xám trung bình

  // Dùng cho các gợi ý (placeholder), văn bản bị vô hiệu hóa.
  static const Color textLight = Color(0xFF9CA3AF); // Màu xám nhạt

  // === CÁC MÀU TIỆN ÍCH KHÁC ===
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color error = Color(0xFFDC2626); // Màu đỏ cho thông báo lỗi
  static const Color success = Color(0xFF16A34A); // Màu xanh lá cho thành công

  /// Tiện ích: Tạo một MaterialColor từ một màu duy nhất để dùng trong ThemeData
  /// ThemeData yêu cầu một Swatch (bảng màu) thay vì một màu đơn lẻ.
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
