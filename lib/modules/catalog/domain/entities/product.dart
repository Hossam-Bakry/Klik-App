import 'package:equatable/equatable.dart';

/// Domain entity used by the presentation layer. Pure Dart — no JSON, no
/// Flutter, no Dio. The data layer maps DTOs into this.
class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.ratingAverage,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double ratingAverage;
  final int ratingCount;

  @override
  List<Object?> get props => [id, title, price, category];
}
