part of 'categories_bloc.dart';

sealed class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the category list.
class CategoriesStarted extends CategoriesEvent {
  const CategoriesStarted();
}

/// Pull-to-refresh — re-fetches without showing the full-screen loader.
class CategoriesRefreshed extends CategoriesEvent {
  const CategoriesRefreshed();
}

/// A category tile was tapped: toggles its inline subcategories panel, or
/// (once resolved) navigates to its products if it has no subcategories.
class CategoryTapped extends CategoriesEvent {
  const CategoryTapped(this.category);

  final Category category;

  @override
  List<Object?> get props => [category];
}

/// Select a category by id from outside the Categories tab (e.g. tapping its
/// thumbnail on the Home tab) — resolves the matching [Category] from the
/// already-loaded list and behaves exactly like [CategoryTapped].
class CategoryTappedById extends CategoriesEvent {
  const CategoryTappedById(this.categoryId);

  final int categoryId;

  @override
  List<Object?> get props => [categoryId];
}
