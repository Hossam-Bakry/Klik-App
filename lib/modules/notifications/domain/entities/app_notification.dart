import 'package:equatable/equatable.dart';

/// What a notification is about — drives its icon and where tapping it goes.
///
/// The backend only sends `type: "order"` today, so [NotificationKind.parse]
/// covers the kinds the design draws and falls back to [general] for anything
/// unrecognised.
enum NotificationKind {
  /// Placed / confirmed — the cart glyph in the design.
  orderPlaced,

  /// On its way — the truck glyph.
  orderDelivery,

  /// Called off.
  orderCancelled,

  /// A return the shop accepted.
  returnApproved,

  /// Promotions and price drops — the tag glyph.
  offer,

  /// Anything else.
  general;

  /// Reads the payload's `type`, then — while every order event arrives as the
  /// same `"order"` type — leans on the wording to tell a delivery from a
  /// confirmation. Drop the second half once the backend sends finer types.
  static NotificationKind parse(String type, String title, String message) {
    final kind = switch (type.toLowerCase().trim()) {
      'offer' || 'promotion' || 'promo' || 'discount' || 'coupon' => offer,
      'return' || 'refund' => returnApproved,
      'order' => null,
      _ => general,
    };
    if (kind != null) return kind;

    final text = '$title $message'.toLowerCase();
    if (text.contains('cancel')) return orderCancelled;
    if (text.contains('deliver') ||
        text.contains('on the way') ||
        text.contains('shipped') ||
        text.contains('pickup')) {
      return orderDelivery;
    }
    return orderPlaced;
  }

  /// Whether the row points at an order, so a tap can open it.
  bool get isOrder =>
      this == orderPlaced ||
      this == orderDelivery ||
      this == orderCancelled ||
      this == returnApproved;
}

/// One row on the notifications screen (`GET /api/notifications`).
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.kind,
    this.reference = '',
    this.timeLabel = '',
    this.isRead = false,
  });

  final int id;
  final String title;
  final String message;
  final NotificationKind kind;

  /// The payload's `url` — an order id for order events, despite the name.
  /// Empty when the notification points at nothing.
  final String reference;

  /// When it arrived, exactly as the server phrased it ("منذ 22 ساعة"). It
  /// sends no machine-readable timestamp, so there's nothing to re-format.
  final String timeLabel;

  final bool isRead;

  /// The order this notification is about, when it names one.
  int? get orderId => kind.isOrder ? int.tryParse(reference.trim()) : null;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    message: message,
    kind: kind,
    reference: reference,
    timeLabel: timeLabel,
    isRead: isRead ?? this.isRead,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    kind,
    reference,
    timeLabel,
    isRead,
  ];
}
