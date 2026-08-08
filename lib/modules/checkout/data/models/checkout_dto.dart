import '../../domain/entities/checkout_summary.dart';
import '../../domain/entities/placed_order.dart';

/// Parses the checkout payloads.
///
/// `POST /api/cart/checkout` answers:
/// ```json
/// { "checkout": { "total_amount": 0.0, "delivery_charge": 0.0,
///                 "coupon_discount": 0.0, "order_tax_amount": 0.0,
///                 "payable_amount": 0.0 },
///   "fulfillment": { … }, "apply_coupon": false, "checkout_items": [] }
/// ```
/// Confirmed 2026-08-07 — though every figure came back zero on a populated
/// cart, whatever parameters were sent, so the caller falls back to the cart's
/// own total.
class CheckoutDto {
  const CheckoutDto._();

  static CheckoutSummary summaryFromJson(Object? data) {
    final checkout = data is Map && data['checkout'] is Map
        ? (data['checkout'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    return CheckoutSummary(
      subtotal: _double(checkout['total_amount']),
      shipping: _double(checkout['delivery_charge']),
      discount: _double(checkout['coupon_discount']),
      tax: _double(checkout['order_tax_amount']),
      total: checkout['payable_amount'] == null
          ? null
          : _double(checkout['payable_amount']),
    );
  }

  /// `POST /api/coupons/apply` → `{ total_order_amount, total_discount_amount }`.
  /// A rejected coupon still answers 200 with a zero discount and an
  /// explanatory `message`, so the caller treats "no discount" as a refusal.
  static double couponDiscountFromJson(Object? data) =>
      data is Map ? _double(data['total_discount_amount']) : 0;

  /// PROVISIONAL — the place-order response is unseen. Accept the spellings the
  /// orders endpoints use, and leave anything missing blank rather than
  /// inventing it.
  static PlacedOrder placedOrderFromJson(Object? data) {
    final order = _orderMap(data);

    return PlacedOrder(
      number: _str(order['order_code'] ?? order['code'] ?? order['id']),
      placedLabel: _str(order['placed_at'] ?? order['created_at']),
      paymentMethodLabel: _str(order['payment_method']),
      total: _double(
        order['payable_amount'] ?? order['amount'] ?? order['total_amount'],
      ),
    );
  }

  /// The newest row of `GET /api/orders` — how the confirmation learns what it
  /// just raised, since `place-order` doesn't say. Same payload the orders
  /// screen parses, so the shape here is confirmed.
  static PlacedOrder latestOrderFromJson(Object? data) {
    final orders = data is Map ? data['orders'] : null;
    final newest = orders is List ? orders.whereType<Map>().firstOrNull : null;
    if (newest == null) return const PlacedOrder();

    final row = newest.cast<String, dynamic>();
    return PlacedOrder(
      number: _str(row['order_code']),
      placedLabel: _str(row['placed_at']),
      paymentMethodLabel: _str(row['payment_method']),
      total: _double(row['amount']),
    );
  }

  /// The order may arrive bare, wrapped in `order`, or — since one cart can
  /// raise an order per shop — as the first of a list.
  static Map<String, dynamic> _orderMap(Object? data) {
    var node = data;
    if (node is Map && node['order'] != null) node = node['order'];
    if (node is Map && node['orders'] is List) node = (node['orders'] as List).firstOrNull;
    if (node is List) node = node.firstOrNull;
    return node is Map ? node.cast<String, dynamic>() : <String, dynamic>{};
  }

  static String _str(Object? v) => v == null ? '' : v.toString().trim();

  static double _double(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);
}
