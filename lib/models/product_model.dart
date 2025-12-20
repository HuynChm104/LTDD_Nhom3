// models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String description;
  final double basePrice;
  final bool isBestSeller;
  final String image;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.basePrice,
    required this.isBestSeller,
    required this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image'] ?? json['picture'];

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      description: json['description'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      isBestSeller: json['isBestSeller'] ?? false,
      image: (rawImage != null && rawImage.toString().startsWith('http'))
          ? rawImage
          : 'https://via.placeholder.com/300x300.png?text=No+Image',
    );
  }

}
