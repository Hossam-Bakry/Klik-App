import 'package:equatable/equatable.dart';

/// A child category nested under a top-level [Category], shown in the
/// Categories tab's inline expansion panel.
class SubCategory extends Equatable {
  const SubCategory({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.categoryId,
  });

  final int id;
  final String name;
  final String thumbnail;

  /// The parent category's id.
  final int categoryId;

  /// Placeholder rows shown under a [Skeletonizer] while subcategories load.
  static List<SubCategory> placeholder() => List.generate(
    3,
    (i) => const SubCategory(
      id: 0,
      name: 'Sub category name',
      thumbnail: '',
      categoryId: 0,
    ),
  );

  @override
  List<Object?> get props => [id, name, thumbnail, categoryId];
}
