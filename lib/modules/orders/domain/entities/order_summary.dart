import 'package:equatable/equatable.dart';

import 'order_status.dart';

/// One row on the Orders list (`GET /api/orders`).
///
/// The list payload carries no shop and no product lines — those only come back
/// from `GET /api/order-details` — so a row shows the order itself: its code,
/// how many units it holds, what it came to, and where it stands.
class OrderSummary extends Equatable {
  const OrderSummary({
    required this.id,
    required this.code,
    required this.status,
    required this.quantity,
    required this.amount,
    required this.placedLabel,
    this.placedAt,
    this.paymentMethod = '',
    this.paymentStatus = '',
  });

  final int id;

  /// Human-facing order number, e.g. `#RC000172`.
  final String code;

  final OrderStatus status;

  /// Total units across the order's lines.
  final int quantity;

  /// What the customer pays (`amount`).
  final double amount;

  /// The server's own formatted stamp, e.g. "07 Aug, 2026 11:43 AM" — shown as
  /// it comes so the app doesn't re-format a date the backend already localised.
  final String placedLabel;

  /// Parsed `created_at`, used for the date-range filter (the label above isn't
  /// machine-readable).
  final DateTime? placedAt;

  final String paymentMethod;
  final String paymentStatus;

  @override
  List<Object?> get props => [
    id,
    code,
    status,
    quantity,
    amount,
    placedLabel,
    placedAt,
    paymentMethod,
    paymentStatus,
  ];
}
