// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final int points;


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
    this.points = 0,

  });


  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      vouchers: data['vouchers'] != null ? List<String>.from(data['vouchers']) : [],
      favoriteBranch: data['favoriteBranch'] ?? '',
      avatar: data['avatar'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      points: data['points'] ?? 0,
    );
  }
}
