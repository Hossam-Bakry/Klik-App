import '../../domain/entities/order_details.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_summary.dart';

/// Parses the orders payloads. Confirmed against the live API on 2026-08-07.
///
/// List (`GET /api/orders`, after the envelope is unwrapped):
/// ```json
/// { "total": 3,
///   "status_wise_orders": { "all": 3, "pending": 3, "delivered": 0, … },
///   "orders": [ { "id": 172, "order_code": "#RC000172", "quantity": 11,
///                 "amount": 47030.0, "order_status": "Pending",
///                 "payment_method": "…", "payment_status": "Pending",
///                 "created_at": "2026-08-07T08:43:10.000000Z",
///                 "placed_at": "07 Aug, 2026 11:43 AM",
///                 "address": { … } } ] }
/// ```
///
/// Details (`GET /api/order-details?order_id=`) wraps everything under
/// `order`, and is the only place the shop and the product lines appear.
class OrdersDto {
  const OrdersDto._();

  static List<OrderSummary> listFromJson(Object? data) {
    final orders = data is Map ? data['orders'] : null;
    if (orders is! List) return const [];
    return orders
        .whereType<Map>()
        .map((row) => _summaryFrom(row.cast<String, dynamic>()))
        .toList();
  }

  static OrderSummary _summaryFrom(Map<String, dynamic> json) => OrderSummary(
    id: _int(json['id']),
    code: _str(json['order_code']),
    status: OrderStatus.parse(_str(json['order_status'])),
    quantity: _int(json['quantity']),
    amount: _double(json['amount']),
    placedLabel: _str(json['placed_at']),
    placedAt: _date(json['created_at']),
    paymentMethod: _str(json['payment_method']),
    paymentStatus: _str(json['payment_status']),
  );

  static OrderDetails detailsFromJson(Object? data) {
    final order = data is Map && data['order'] is Map
        ? (data['order'] as Map).cast<String, dynamic>()
        // Tolerate the order arriving unwrapped.
        : (data is Map ? data.cast<String, dynamic>() : <String, dynamic>{});

    final products = order['products'];

    return OrderDetails(
      id: _int(order['id']),
      code: _str(order['order_code']),
      status: OrderStatus.parse(_str(order['order_status'])),
      products: products is List
          ? products
                .whereType<Map>()
                .map((row) => _lineFrom(row.cast<String, dynamic>()))
                .toList()
          : const [],
      shop: order['shop'] is Map
          ? _shopFrom((order['shop'] as Map).cast<String, dynamic>())
          : null,
      address: order['address'] is Map
          ? _addressFrom((order['address'] as Map).cast<String, dynamic>())
          : null,
      placedLabel: _str(order['placed_at']),
      placedAt: _date(order['created_at']),
      estimatedDelivery: _str(order['estimated_delivery_date']),
      paymentMethod: _str(order['payment_method']),
      paymentStatus: _str(order['payment_status']),
      subtotal: _double(order['total_amount']),
      tax: _double(order['tax_amount']),
      discount: _double(order['discount']),
      couponDiscount: _double(order['coupon_discount']),
      deliveryCharge: _double(order['delivery_charge']),
      payableAmount: _double(order['payable_amount']),
      quantity: _int(order['quantity']),
      invoiceUrl: _str(order['invoice_url']),
    );
  }

  static OrderLine _lineFrom(Map<String, dynamic> json) => OrderLine(
    productId: _int(json['id']),
    name: _str(json['name']),
    thumbnail: _str(json['thumbnail']),
    price: _double(json['price']),
    discountPrice: _double(json['discount_price']),
    // A line always holds at least one unit.
    quantity: _int(json['order_qty']).clamp(1, 1 << 31),
    color: _str(json['color']),
    size: _str(json['size']),
    unit: _str(json['unit']),
  );

  static OrderShop _shopFrom(Map<String, dynamic> json) => OrderShop(
    id: _int(json['id']),
    name: _str(json['name']),
    logo: _str(json['logo']),
    rating: _double(json['rating']),
  );

  static OrderAddress _addressFrom(Map<String, dynamic> json) => OrderAddress(
    id: _int(json['id']),
    name: _str(json['name']),
    phone: _str(json['phone']),
    type: _str(json['address_type']),
    area: _str(json['area']),
    flatNo: _str(json['flat_no']),
    line1: _str(json['address_line']),
    line2: _str(json['address_line2']),
    postCode: _str(json['post_code']),
  );

  /// `null` stringifies to "null", which would show up on screen — keep the
  /// many nullable text fields ("brand", "unit", "color", …) empty instead.
  static String _str(Object? v) => v == null ? '' : v.toString().trim();

  static int _int(Object? v) => switch (v) {
    num n => n.toInt(),
    String s => int.tryParse(s) ?? 0,
    _ => 0,
  };

  static double _double(Object? v) =>
      v == null ? 0 : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0);

  static DateTime? _date(Object? v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;
}
