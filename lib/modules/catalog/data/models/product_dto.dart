import '../../domain/entities/product.dart';

/// Data Transfer Object: knows how to parse the API's JSON shape and convert
/// to the domain [Product]. Manual `fromJson` keeps the project codegen-free;
/// swap for freezed + json_serializable later if you want generated parsers.
class ProductDto {
  const ProductDto({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.ratingRate,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double ratingRate;
  final int ratingCount;

  /// Throwing on bad JSON is fine — DioApiClient catches decode errors and
  /// turns them into a ParsingFailure.
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] as Map<String, dynamic>?;
    return ProductDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      ratingRate: (rating?['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: (rating?['count'] as num?)?.toInt() ?? 0,
    );
  }

  Product toEntity() => Product(
        id: id,
        title: title,
        price: price,
        description: description,
        category: category,
        imageUrl: image,
        ratingAverage: ratingRate,
        ratingCount: ratingCount,
      );
}
