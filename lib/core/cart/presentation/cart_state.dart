part of 'cart_cubit.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart = Cart.empty,
    this.errorMessage,
    this.isMutating = false,
  });

  final CartStatus status;
  final Cart cart;
  final String? errorMessage;

  /// A quantity change / removal is in flight. The list stays on screen; only
  /// the steppers lock so a double-tap can't race itself.
  final bool isMutating;

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
    bool? isMutating,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => [status, cart, errorMessage, isMutating];
}
