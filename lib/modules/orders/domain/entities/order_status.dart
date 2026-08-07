import '../../../../core/localization/locale_keys.dart';

/// Where an order stands. Mirrors `order_status` on `GET /api/orders` and the
/// buckets in its `status_wise_orders` map.
enum OrderStatus {
  pending,
  confirmed,
  processing,
  pickup,
  onTheWay,
  delivered,
  cancelled;

  /// The backend spells these inconsistently ("Pending", "on_the_way", …), so
  /// normalise before matching. An unknown status reads as [pending] — an order
  /// that exists has at least been placed.
  static OrderStatus parse(String raw) =>
      switch (raw.toLowerCase().replaceAll(RegExp(r'[\s-]'), '_')) {
        'confirm' || 'confirmed' => confirmed,
        'processing' => processing,
        'pickup' || 'picked_up' => pickup,
        'on_the_way' || 'on_delivery' || 'out_for_delivery' => onTheWay,
        'delivered' || 'completed' => delivered,
        'cancelled' || 'canceled' || 'rejected' => cancelled,
        _ => pending,
      };

  String get labelKey => switch (this) {
    pending => LocaleKeys.orderPending,
    confirmed => LocaleKeys.orderConfirmed,
    processing => LocaleKeys.orderProcessing,
    pickup => LocaleKeys.orderPickup,
    onTheWay => LocaleKeys.orderOnDelivery,
    delivered => LocaleKeys.orderDelivered,
    cancelled => LocaleKeys.orderCancelled,
  };

  bool get isDelivered => this == delivered;

  bool get isCancelled => this == cancelled;

  /// Still on its way — everything that hasn't finished one way or the other.
  /// This is what the list's "Pending" chip selects, so an order that's being
  /// processed or is out for delivery doesn't fall between the chips.
  bool get isInProgress => !isDelivered && !isCancelled;

  /// Cancellable until the shop hands it to a rider.
  bool get isCancellable =>
      this == pending || this == confirmed || this == processing;

  /// Which step of the [OrderStage] timeline the order has reached, or null
  /// for a cancelled order — that one doesn't sit on the happy path.
  OrderStage? get stage => switch (this) {
    pending => OrderStage.placed,
    confirmed || processing => OrderStage.processing,
    pickup || onTheWay => OrderStage.onDelivery,
    delivered => OrderStage.delivered,
    cancelled => null,
  };
}

/// The list screen's filter chips. The design offers three buckets next to
/// "All"; [inProgress] deliberately swallows every unfinished status so no
/// order falls between the chips.
enum OrderListFilter {
  inProgress(LocaleKeys.pending),
  delivered(LocaleKeys.orderDelivered),
  cancelled(LocaleKeys.orderCancelled);

  const OrderListFilter(this.labelKey);

  final String labelKey;

  bool matches(OrderStatus status) => switch (this) {
    inProgress => status.isInProgress,
    delivered => status.isDelivered,
    cancelled => status.isCancelled,
  };
}

/// The four steps the order-details timeline walks through. Several API
/// statuses collapse into one step (confirm + processing, pickup + on the way),
/// which is what the design draws.
enum OrderStage {
  placed,
  processing,
  onDelivery,
  delivered;

  String get labelKey => switch (this) {
    placed => LocaleKeys.orderPending,
    processing => LocaleKeys.orderProcessing,
    onDelivery => LocaleKeys.orderOnDelivery,
    delivered => LocaleKeys.orderDelivered,
  };
}
