import 'package:equatable/equatable.dart';

/// A top-level catalog category shown on the Categories tab.
class Category extends Equatable {
  const Category({required this.id, required this.name, required this.thumbnail});

  final int id;
  final String name;
  final String thumbnail;

  /// Placeholder rows shown under a [Skeletonizer] while categories load.
  static List<Category> placeholder() => List.generate(
    9,
    (i) => const Category(id: 0, name: 'Category name', thumbnail: ''),
  );

  @override
  List<Object?> get props => [id, name, thumbnail];
}
