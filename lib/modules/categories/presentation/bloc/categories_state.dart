part of 'categories_bloc.dart';

enum CategoriesStatus { initial, loading, success, failure }

enum SubCategoriesStatus { idle, loading, success, failure }

class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.expandedCategoryId,
    this.subCategoriesStatus = SubCategoriesStatus.idle,
    this.subCategoriesCache = const {},
    this.subCategoriesErrorMessage,
    this.navigateToCategory,
    this.navigationToken = 0,
  });

  final CategoriesStatus status;
  final List<Category> categories;
  final String? errorMessage;

  /// The category whose subcategories panel is expanded inline (null = none).
  final int? expandedCategoryId;
  final SubCategoriesStatus subCategoriesStatus;

  /// Per-category subcategory cache, so re-tapping a tile doesn't refetch.
  final Map<int, List<SubCategory>> subCategoriesCache;
  final String? subCategoriesErrorMessage;

  /// Set (with a bumped [navigationToken]) when a tapped category turns out to
  /// have no subcategories. The page's `BlocListener` reacts once per token
  /// bump and pushes the category-products page.
  final Category? navigateToCategory;
  final int navigationToken;

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<Category>? categories,
    String? errorMessage,
    int? expandedCategoryId,
    bool clearExpandedCategoryId = false,
    SubCategoriesStatus? subCategoriesStatus,
    Map<int, List<SubCategory>>? subCategoriesCache,
    String? subCategoriesErrorMessage,
    Category? navigateToCategory,
    int? navigationToken,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      expandedCategoryId: clearExpandedCategoryId
          ? null
          : (expandedCategoryId ?? this.expandedCategoryId),
      subCategoriesStatus: subCategoriesStatus ?? this.subCategoriesStatus,
      subCategoriesCache: subCategoriesCache ?? this.subCategoriesCache,
      subCategoriesErrorMessage: subCategoriesErrorMessage,
      navigateToCategory: navigateToCategory ?? this.navigateToCategory,
      navigationToken: navigationToken ?? this.navigationToken,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        errorMessage,
        expandedCategoryId,
        subCategoriesStatus,
        subCategoriesCache,
        subCategoriesErrorMessage,
        navigateToCategory,
        navigationToken,
      ];
}
