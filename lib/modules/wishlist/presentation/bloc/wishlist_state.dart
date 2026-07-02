part of 'wishlist_bloc.dart';

enum WishlistStatus { initial, loading, success, failure }

class WishlistState extends Equatable {
  const WishlistState({
    this.status = WishlistStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  final WishlistStatus status;

  /// All favorites returned by the API. The page hides any whose id is no
  /// longer in the global [FavoritesCubit] (i.e. just unfavorited).
  final List<HomeProduct> products;

  final String? errorMessage;

  bool get isLoading =>
      status == WishlistStatus.initial || status == WishlistStatus.loading;

  WishlistState copyWith({
    WishlistStatus? status,
    List<HomeProduct>? products,
    String? errorMessage,
  }) {
    return WishlistState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, products, errorMessage];
}
