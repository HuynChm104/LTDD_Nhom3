// models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final List<String> vouchers;
  final String favoriteBranch;
  final String avatar;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.vouchers,
    required this.favoriteBranch,
    required this.avatar,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      vouchers: List<String>.from(json['vouchers']) ?? [],
      favoriteBranch: json['favoriteBranch'] ?? '',
      avatar: json['avatar'] ?? '',
      createdAt: DateTime.parse(json['createdAt']) ?? DateTime.now(),
    );
  }
}

