import 'package:equatable/equatable.dart';

import 'order_status.dart';

/// A placed order in full (`GET /api/order-details?order_id=`): what was
/// bought, from whom, where it's going, and what it came to.
class OrderDetails extends Equatable {
  const OrderDetails({
    required this.id,
    required this.code,
    required this.status,
    required this.products,
    this.shop,
    this.address,
    this.placedLabel = '',
    this.placedAt,
    this.estimatedDelivery = '',
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.subtotal = 0,
    this.tax = 0,
    this.discount = 0,
    this.couponDiscount = 0,
    this.deliveryCharge = 0,
    this.payableAmount = 0,
    this.quantity = 0,
    this.invoiceUrl = '',
  });

  final int id;
  final String code;
  final OrderStatus status;
  final List<OrderLine> products;
  final OrderShop? shop;
  final OrderAddress? address;

  /// The server's formatted placement stamp, e.g. "07 Aug, 2026 11:43 AM".
  final String placedLabel;
  final DateTime? placedAt;

  /// As the API phrases it (already localised, e.g. "3 أيام") — the timeline's
  /// last step shows it as the expected delivery.
  final String estimatedDelivery;

  final String paymentMethod;
  final String paymentStatus;

  /// Lines before shipping and discounts (`total_amount`).
  final double subtotal;
  final double tax;
  final double discount;
  final double couponDiscount;
  final double deliveryCharge;

  /// What the customer actually pays (`payable_amount`).
  final double payableAmount;

  /// Total units across the lines.
  final int quantity;

  final String invoiceUrl;

  /// Discount and coupon are separate fields but read as one line on the
  /// summary, the way the design shows it.
  double get totalDiscount => discount + couponDiscount;

  @override
  List<Object?> get props => [
    id,
    code,
    status,
    products,
    shop,
    address,
    placedLabel,
    placedAt,
    estimatedDelivery,
    paymentMethod,
    paymentStatus,
    subtotal,
    tax,
    discount,
    couponDiscount,
    deliveryCharge,
    payableAmount,
    quantity,
    invoiceUrl,
  ];
}

/// One product line on an order.
class OrderLine extends Equatable {
  const OrderLine({
    required this.productId,
    required this.name,
    required this.thumbnail,
    required this.price,
    this.discountPrice = 0,
    this.quantity = 1,
    this.color = '',
    this.size = '',
    this.unit = '',
  });

  final int productId;
  final String name;
  final String thumbnail;

  /// List price of one unit.
  final double price;

  /// Price actually charged when the line was discounted; `0` otherwise.
  final double discountPrice;

  /// Units ordered (`order_qty`).
  final int quantity;

  final String color;
  final String size;
  final String unit;

  bool get hasDiscount => discountPrice > 0 && discountPrice < price;

  double get effectivePrice => hasDiscount ? discountPrice : price;

  double get lineTotal => effectivePrice * quantity;

  /// "512g / Black", or empty when the product doesn't vary.
  String get variantLabel =>
      [size, color].where((part) => part.isNotEmpty).join(' / ');

  @override
  List<Object?> get props => [
    productId,
    name,
    thumbnail,
    price,
    discountPrice,
    quantity,
    color,
    size,
    unit,
  ];
}

/// The shop an order was placed with.
class OrderShop extends Equatable {
  const OrderShop({
    required this.id,
    required this.name,
    this.logo = '',
    this.rating = 0,
  });

  final int id;
  final String name;
  final String logo;
  final double rating;

  @override
  List<Object?> get props => [id, name, logo, rating];
}

/// Where the order is going. Same shape the addresses module uses, kept local
/// so the orders module doesn't depend on it.
class OrderAddress extends Equatable {
  const OrderAddress({
    required this.id,
    this.name = '',
    this.phone = '',
    this.type = '',
    this.area = '',
    this.flatNo = '',
    this.line1 = '',
    this.line2 = '',
    this.postCode = '',
  });

  final int id;
  final String name;
  final String phone;

  /// "Home" / "Work" / "Other".
  final String type;

  final String area;
  final String flatNo;
  final String line1;
  final String line2;
  final String postCode;

  /// The address as one line, skipping the parts the customer left blank.
  String get formatted => [
    flatNo,
    line1,
    line2,
    area,
    postCode,
  ].where((part) => part.trim().isNotEmpty).join(', ');

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    type,
    area,
    flatNo,
    line1,
    line2,
    postCode,
  ];
}
