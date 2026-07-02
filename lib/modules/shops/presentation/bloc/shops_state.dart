part of 'shops_bloc.dart';

enum ShopsStatus { initial, loading, success, failure }

class ShopsState extends Equatable {
  const ShopsState({
    this.status = ShopsStatus.initial,
    this.shops = const [],
    this.errorMessage,
  });

  final ShopsStatus status;
  final List<ShopItem> shops;
  final String? errorMessage;

  bool get isLoading =>
      status == ShopsStatus.initial || status == ShopsStatus.loading;

  ShopsState copyWith({
    ShopsStatus? status,
    List<ShopItem>? shops,
    String? errorMessage,
  }) {
    return ShopsState(
      status: status ?? this.status,
      shops: shops ?? this.shops,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, shops, errorMessage];
}
