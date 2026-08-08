import 'package:equatable/equatable.dart';

/// What the success screen shows after `POST /api/place-order`.
///
/// PROVISIONAL: the response has never been seen — reading it means placing a
/// real order — so [PlacedOrderDto] accepts the field names the rest of the
/// API uses and every part here tolerates being missing.
class PlacedOrder extends Equatable {
  const PlacedOrder({
    this.number = '',
    this.placedLabel = '',
    this.paymentMethodLabel = '',
    this.total = 0,
  });

  /// Human-facing order number, e.g. `#RC000176`.
  final String number;

  /// When it was placed, as the server phrased it.
  final String placedLabel;

  final String paymentMethodLabel;
  final double total;

  bool get isEmpty => number.isEmpty && placedLabel.isEmpty && total <= 0;

  PlacedOrder copyWith({
    String? number,
    String? placedLabel,
    String? paymentMethodLabel,
    double? total,
  }) => PlacedOrder(
    number: number ?? this.number,
    placedLabel: placedLabel ?? this.placedLabel,
    paymentMethodLabel: paymentMethodLabel ?? this.paymentMethodLabel,
    total: total ?? this.total,
  );

  @override
  List<Object?> get props => [number, placedLabel, paymentMethodLabel, total];
}
