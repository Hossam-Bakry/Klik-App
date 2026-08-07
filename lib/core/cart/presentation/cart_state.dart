part of 'cart_cubit.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart = Cart.empty,
    this.errorMessage,
    this.pendingProductIds = const {},
  });

  final CartStatus status;
  final Cart cart;
  final String? errorMessage;

  /// Products with a change in flight. Tracked per product rather than as one
  /// flag so locking a row's stepper against a double-tap doesn't freeze every
  /// other row (or every product card on screen) along with it.
  final Set<int> pendingProductIds;

  /// Whether this product is mid-change — the caller's stepper dims until its
  /// own new quantity lands.
  bool isPending(int productId) => pendingProductIds.contains(productId);

  /// A fetch is in flight with nothing to show yet — the screen renders its
  /// skeleton.
  ///
  /// `initial` is deliberately *not* loading: the cubit is seeded from the
  /// device at construction, so before any fetch the state is already truthful.
  /// Treating it as loading left an empty guest cart shimmering forever, since
  /// nothing moves the status off `initial` on its own.
  bool get isLoading => cart.isEmpty && status == CartStatus.loading;

  int get itemCount => cart.itemCount;

  CartState copyWith({
    CartStatus? status,
    Cart? cart,
    String? errorMessage,
    bool clearError = false,
    Set<int>? pendingProductIds,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingProductIds: pendingProductIds ?? this.pendingProductIds,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage, pendingProductIds];
}
