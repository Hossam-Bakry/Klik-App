import 'package:equatable/equatable.dart';

import 'cart_item.dart';

/// The cart as a whole — whichever side currently owns it (the device while the
/// user is a guest, the server once they sign in).
class Cart extends Equatable {
  const Cart({this.items = const []});

  final List<CartItem> items;

  static const empty = Cart();

  bool get isEmpty => items.isEmpty;

  /// Badge count — total units, not distinct lines.
  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Summed from the lines on both sides. The cart payload's `total` is a
  /// *count* of lines, not money, so there's no server figure to prefer.
  double get total =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  Cart copyWith({List<CartItem>? items}) => Cart(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}
