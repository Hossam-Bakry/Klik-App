import 'package:equatable/equatable.dart';

/// Where one of the customer's offers stands. Mirrors the `groups` keys (and
/// each bid's own `status`) in `GET /api/bids`.
enum NegotiationStatus {
  /// Sent, waiting on the seller.
  pending,

  /// The seller agreed — shown as "Approved" on the card, "Accepted" as a tab.
  approved,

  /// The seller turned it down.
  rejected,

  /// The agreed price ran out of time.
  expired;

  static NegotiationStatus? parse(String raw) => switch (raw.toLowerCase()) {
    'pending' => pending,
    'approved' || 'accepted' => approved,
    'rejected' || 'declined' => rejected,
    'expired' => expired,
    _ => null,
  };
}

/// One row on the "My Negotiations" screen: the product the offer was made on,
/// plus the offer itself (amount, the seller's answer, where it stands).
class Negotiation extends Equatable {
  const Negotiation({
    required this.bidId,
    required this.productId,
    required this.name,
    required this.thumbnail,
    required this.status,
    required this.bidAmount,
    required this.listedPrice,
    this.variantLabel = '',
    this.counterAmount,
    this.agreedAmount,
    this.expiresAt,
    this.isExpired = false,
    this.submittedAt,
  });

  final int bidId;
  final int productId;
  final String name;
  final String thumbnail;

  final NegotiationStatus status;

  /// What the customer offered (`price.bid_amount`).
  final double bidAmount;

  /// The product's price without a deal (`price.listed_price`) — struck through
  /// next to the negotiated one.
  final double listedPrice;

  /// e.g. "512g / Black". Empty when the product has no variants.
  final String variantLabel;

  /// The seller's counter, when they answered with a price of their own.
  final double? counterAmount;

  /// The live agreed price (`price.amount` while `price.active`).
  final double? agreedAmount;

  /// When the agreed price stops counting (`price.expires_at`).
  final DateTime? expiresAt;

  /// The API's own `price.expired` flag.
  final bool isExpired;

  /// When the offer was sent — the date shown on the card.
  final DateTime? submittedAt;

  /// The price the card leads with: what the customer actually pays once a deal
  /// is on the table, otherwise their own offer.
  double get effectivePrice => agreedAmount ?? counterAmount ?? bidAmount;

  /// Saving against the listed price, as the card's "7%" badge. 0 when the
  /// negotiation gains nothing (or the listed price is missing).
  int get discountPercent => listedPrice <= 0 || effectivePrice >= listedPrice
      ? 0
      : ((listedPrice - effectivePrice) / listedPrice * 100).round();

  /// Time left on the deal, or null when there's no live deadline — drives the
  /// card's "04:50 h" line.
  Duration? get timeLeft {
    final until = expiresAt;
    if (until == null || isExpired) return null;
    final left = until.difference(DateTime.now());
    return left.isNegative ? null : left;
  }

  @override
  List<Object?> get props => [
    bidId,
    productId,
    name,
    thumbnail,
    status,
    bidAmount,
    listedPrice,
    variantLabel,
    counterAmount,
    agreedAmount,
    expiresAt,
    isExpired,
    submittedAt,
  ];
}
