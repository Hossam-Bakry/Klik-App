import 'package:equatable/equatable.dart';

/// A top-level catalog category in the home "Categories" strip.
class CategoryItem extends Equatable {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  final int id;
  final String name;
  final String thumbnail;

  @override
  List<Object?> get props => [id, name, thumbnail];
}
