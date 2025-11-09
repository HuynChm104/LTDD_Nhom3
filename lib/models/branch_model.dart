// models/branch_model.dart
import 'dart:math';

class BranchModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  /// Từ Firestore → BranchModel
  factory BranchModel.fromJson(String id, Map<String, dynamic> json) {
    return BranchModel(
      id: id,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Tính khoảng cách (km) từ vị trí hiện tại đến chi nhánh
  double distanceTo(double lat, double lng) {
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