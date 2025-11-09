// models/review_model.dart
class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      productId: json['productId'] ?? '',
      rating: json['rating'] ?? 0.0,
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']) ?? DateTime.now(),
    );
  }
}
