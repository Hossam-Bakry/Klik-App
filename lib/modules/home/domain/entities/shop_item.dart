import 'package:equatable/equatable.dart';

/// A merchant shown in the home "Shops" strip.
class ShopItem extends Equatable {
  const ShopItem({
    required this.id,
    required this.name,
    required this.logo,
    required this.rating,
    required this.totalProducts,
    required this.isOnline,
  });

  final int id;
  final String name;
  final String logo;
  final double rating;
  final int totalProducts;
  final bool isOnline;

  @override
  List<Object?> get props => [id, name, logo, rating, isOnline];
}
