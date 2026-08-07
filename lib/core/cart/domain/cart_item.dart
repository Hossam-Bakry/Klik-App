import 'package:equatable/equatable.dart';

/// One line in the cart.
///
/// A guest's cart lives entirely on the device, so a line has to carry
/// everything the cart screen renders (name, thumbnail, price) — there's no
/// product lookup to fall back on until the user signs in.
class CartItem extends Equatable {
  const CartItem({
    required this.productId,
    required this.name,
    required this.thumbnail,
    required this.price,
    this.shopId = 0,
    this.originalPrice = 0,
    this.quantity = 1,
    this.sizeId,
    this.colorId,
    this.unit = '',
  });

  /// The line is identified by its product (plus variant) on both sides: the
  /// device store keys on it, and every cart endpoint takes `product_id` — the
  /// backend exposes no cart-row id.
  final int productId;
  /// Which shop sells it. The server's cart is grouped by shop, and both
  /// checkout (`shop_ids`) and the coupon endpoint need it; `0` on a guest
  /// line, which has no group to sit in.
  final int shopId;

  final String name;
  final String thumbnail;

  /// Unit price actually charged.
  final double price;

  /// Pre-discount unit price, struck through on the card. `0` when the product
  /// carries no discount.
  final double originalPrice;

  final int quantity;

  /// Selected variant, as `/cart/store` and `/cart/merge` expect them
  /// (`size` / `color`). Null on a product that doesn't vary by that axis.
  final int? sizeId;
  final int? colorId;

  /// The product's unit label, echoed back on the merge payload.
  final String unit;

  /// What this line costs.
  double get lineTotal => price * quantity;

  bool get hasDiscount => originalPrice > 0 && originalPrice > price;

  /// Two lines are the same cart entry when they're the same product *and* the
  /// same variant — adding a different size of the same product is its own row.
  bool sameLineAs(CartItem other) =>
      productId == other.productId &&
      sizeId == other.sizeId &&
      colorId == other.colorId;

  CartItem copyWith({int? quantity}) => CartItem(
    productId: productId,
    shopId: shopId,
    name: name,
    thumbnail: thumbnail,
    price: price,
    originalPrice: originalPrice,
    quantity: quantity ?? this.quantity,
    sizeId: sizeId,
    colorId: colorId,
    unit: unit,
  );

  @override
  List<Object?> get props => [
    productId,
    shopId,
    name,
    thumbnail,
    price,
    originalPrice,
    quantity,
    sizeId,
    colorId,
    unit,
  ];
}
