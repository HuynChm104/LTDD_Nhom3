// lib/models/branch_model.dart
import 'dart:math';

class BranchModel {
  final String id;
  final String name;
  final String address;
  double latitude;  // <-- Bỏ 'final' để có thể gán lại giá trị
  double longitude; // <-- Bỏ 'final' để có thể gán lại giá trị

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    this.latitude = 0.0,  // <-- Thêm giá trị mặc định
    this.longitude = 0.0, // <-- Thêm giá trị mặc định
  });

  /// Từ Firestore → BranchModel
  factory BranchModel.fromJson(String id, Map<String, dynamic> json) {
    // Bây giờ, ta chỉ cần đọc address. Tọa độ sẽ được cập nhật sau.
    return BranchModel(
      id: id,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      // Không cần đọc latitude/longitude từ Firestore nữa vì ta sẽ tự tìm nó
    );
  }

  /// Tính khoảng cách (km) từ vị trí hiện tại đến chi nhánh
  double distanceTo(double lat, double lng) {
    if (latitude == 0.0 || longitude == 0.0) {
      // Nếu chi nhánh không có tọa độ hợp lệ, trả về khoảng cách vô cùng
      return double.infinity;
    }
    const double R = 6371.0; // Bán kính Trái Đất (km)
    final double dLat = _toRadians(lat - latitude);
    final double dLng = _toRadians(lng - longitude);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(_toRadians(latitude)) * cos(_toRadians(lat)) *
                sin(dLng / 2) * sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  /// Chuyển độ → radian
  double _toRadians(double degree) => degree * pi / 180;
}
