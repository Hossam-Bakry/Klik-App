import 'package:equatable/equatable.dart';

/// What the customer is about to pay.
///
/// `POST /api/cart/checkout` is the source, but it currently answers with an
/// all-zero summary whatever we send it, so [resolvedAgainst] falls back to the
/// cart's own line total. Shipping and tax stay at whatever the server reports
/// — there's nothing on the client to derive them from.
class CheckoutSummary extends Equatable {
  const CheckoutSummary({
    this.subtotal = 0,
    this.shipping = 0,
    this.discount = 0,
    this.tax = 0,
    double? total,
  }) : _total = total;

  final double subtotal;
  final double shipping;
  final double discount;
  final double tax;

  final double? _total;

  static const empty = CheckoutSummary();

  /// The server's payable amount when it gave one, else the parts added up.
  double get total =>
      _total ?? (subtotal + shipping + tax - discount).clamp(0, double.infinity);

  /// Fills the gaps the endpoint left: the cart's own total stands in for a
  /// missing subtotal, and a coupon applied on the client overrides the
  /// server's discount.
  CheckoutSummary resolvedAgainst({
    required double cartTotal,
    double? couponDiscount,
  }) {
    final resolvedSubtotal = subtotal > 0 ? subtotal : cartTotal;
    final resolvedDiscount = couponDiscount ?? discount;

    return CheckoutSummary(
      subtotal: resolvedSubtotal,
      shipping: shipping,
      discount: resolvedDiscount,
      tax: tax,
      // Only trust the server's payable amount while nothing has been
      // recalculated underneath it.
      total: subtotal > 0 && couponDiscount == null ? _total : null,
    );
  }

  @override
  List<Object?> get props => [subtotal, shipping, discount, tax, _total];
}
