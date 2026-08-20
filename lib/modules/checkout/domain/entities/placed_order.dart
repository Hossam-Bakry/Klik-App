import 'package:equatable/equatable.dart';

import 'payment_method.dart';

/// What the success screen shows after `POST /api/place-order`.
///
/// PROVISIONAL: the response has never been seen — reading it means placing a
/// real order — so [PlacedOrderDto] accepts the field names the rest of the
/// API uses and every part here tolerates being missing.
class PlacedOrder extends Equatable {
  const PlacedOrder({
    this.number = '',
    this.placedLabel = '',
    this.method,
    this.paymentMethodLabel = '',
    this.total = 0,
  });

  /// Human-facing order number, e.g. `#RC000176`.
  final String number;

  /// When it was placed, as the server phrased it.
  final String placedLabel;

  /// How it's being paid, resolved to one of the app's own methods so the
  /// confirmation shows a localized name ("Cash on Delivery") rather than the
  /// server's raw slug. Null when nothing recognisable came back.
  final PaymentMethod? method;

  /// The server's own wording, kept as the fallback for when [method] is null.
  final String paymentMethodLabel;

  final double total;

  bool get isEmpty => number.isEmpty && placedLabel.isEmpty && total <= 0;

  /// Whether there's anything to show on the payment row.
  bool get hasPaymentMethod => method != null || paymentMethodLabel.isNotEmpty;

  PlacedOrder copyWith({
    String? number,
    String? placedLabel,
    PaymentMethod? method,
    String? paymentMethodLabel,
    double? total,
  }) => PlacedOrder(
    number: number ?? this.number,
    placedLabel: placedLabel ?? this.placedLabel,
    method: method ?? this.method,
    paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
    total: total ?? this.total,
  );

  @override
  List<Object?> get props => [
    number,
    placedLabel,
    method,
    paymentMethodLabel,
    total,
  ];
}
