import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyHistoryModel {
  final String id;
  final String title;
  final int points;
  final DateTime date;
  final String type; // 'earn' (cộng) hoặc 'redeem' (trừ)

  LoyaltyHistoryModel({
    required this.id,
    required this.title,
    required this.points,
    required this.date,
    required this.type,
  });

  // Chuyển dữ liệu từ Firestore thành đối tượng Dart
  factory LoyaltyHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoyaltyHistoryModel(
      id: doc.id,
      title: data['title'] ?? '',
      points: data['points'] ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'earn',
    );
  }
}