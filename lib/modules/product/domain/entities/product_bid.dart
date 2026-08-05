import 'package:equatable/equatable.dart';

/// State of the customer's most recent offer on a bidable product, derived from
/// the API's `last_bid.state` combined with the variant's `price` object (the
/// seller's price on the table): `pending`/`rejected` become [pending]/[declined]
/// on their own, or [countered]/declined-with-offer when a `price` is active;
/// `accepted` → [approved]; `none` → null; and an expired `price` → [expired].
enum BidStatus {
  /// Sent, waiting on the seller.
  pending,

  /// Turned down — the customer may offer again (if attempts remain). The
  /// seller may still leave a standing price (see [ProductBid.counteredPrice]).
  declined,

  /// The seller answered with a price of their own, to accept or negotiate
  /// against before [ProductBid.expiresAt].
  countered,

  /// Seller agreed; the customer must buy before [ProductBid.expiresAt].
  approved,

  /// An approved/countered price ran out of time — a fresh bid is needed.
  expired,
}

/// The signed-in customer's negotiation on a bidable product: the daily attempt
/// allowance, where their last offer stands, and the prices in play (their own
/// offer, the system's suggestion, the approved price). Only ever visible to its
/// owner.
///
/// Parsed from the product-details `bid` object's *selected variant* (see
/// `ProductDetailsDto._bidFromJson`): a flat view of one variant's state, the
/// product-per-day attempt bucket, and its recommended/minimum amounts.
class ProductBid extends Equatable {
  const ProductBid({
    this.variantKey,
    this.sizeId,
    this.colorId,
    this.listedPrice,
    this.status,
    this.attemptsUsed = 0,
    this.dailyLimit = 3,
    this.offeredPrice,
    this.counteredPrice,
    this.suggestedPrice,
    this.acceptedPrice,
    this.minimumOffer,
    this.minimumOfferPercent,
    this.expiresAt,
    this.canSubmit = true,
  });

  /// The variant this bid belongs to (`key`, e.g. `"3:5"`) — the app negotiates
  /// one variant at a time, resolved from the customer's size/colour pick.
  final String? variantKey;

  /// Variant identity used to match the customer's selection (`size_id` /
  /// `color_id`). Null on the side the product doesn't vary by.
  final int? sizeId;
  final int? colorId;

  /// The variant's own listed price (`listed_price`) — offers are negotiated
  /// against this, which can differ per variant. Null falls back to the
  /// product's price at the call site.
  final double? listedPrice;

  /// `null` when no offer has been sent yet — no status banner is shown.
  final BidStatus? status;

  /// Bids placed today, out of [dailyLimit] — drives the "Daily bid limit"
  /// pills (filled = used). Sourced from `rules.attempts.product_per_day`.
  final int attemptsUsed;
  final int dailyLimit;

  /// The customer's last offer (`last_bid.amount`).
  final double? offeredPrice;

  /// The seller's standing price ("Seller Offer" / "Countered price"), from the
  /// variant's active `price.amount`. Present while countered, or alongside a
  /// decline when the seller left a price to take.
  final double? counteredPrice;

  /// Price the app suggests the customer offer ("Suggested Offer",
  /// `recommended_bid`).
  final double? suggestedPrice;

  /// Price the seller agreed to; what the customer pays while it holds
  /// (`price.amount` on an accepted, still-live offer).
  final double? acceptedPrice;

  /// Lowest offer the seller will consider (`minimum_bid_amount`). Drives the
  /// "offer is too small" error; when null the only rule is "below the listed
  /// price".
  final double? minimumOffer;

  /// The same floor expressed as a share of the listed price
  /// (`rules.minimum_bid_percentage`, e.g. `90.0` → offers must be ≥ 90% of the
  /// listed price). Product-wide, so it also covers variants that arrive without
  /// their own [minimumOffer]. See [minimumOfferFor].
  final double? minimumOfferPercent;

  /// When the approved offer stops counting (`price.expires_at`).
  final DateTime? expiresAt;

  /// The API's own `can_submit` for the selected variant — false when the
  /// variant is locked out for reasons beyond the attempt count.
  final bool canSubmit;

  /// Attempts the customer may still spend today.
  int get attemptsLeft => (dailyLimit - attemptsUsed).clamp(0, dailyLimit);

  /// The lowest offer the seller will take on a variant listed at [listedPrice]:
  /// the stricter of [minimumOffer] and [minimumOfferPercent] of the price. Null
  /// when the API set neither — then the only rule is "below the listed price".
  double? minimumOfferFor(double listedPrice) {
    final percent = minimumOfferPercent;
    final byPercent = percent != null && percent > 0 && listedPrice > 0
        ? listedPrice * percent / 100
        : null;
    final byAmount = minimumOffer;
    if (byAmount == null) return byPercent;
    if (byPercent == null) return byAmount;
    return byAmount > byPercent ? byAmount : byPercent;
  }

  bool get isPending => status == BidStatus.pending;
  bool get isDeclined => status == BidStatus.declined;
  bool get isCountered => status == BidStatus.countered;
  bool get isApproved => status == BidStatus.approved;
  bool get isExpired => status == BidStatus.expired;

  /// A live approved offer — the page swaps in [acceptedPrice] and the CTA
  /// becomes "complete your purchase".
  bool get hasLivePrice => isApproved && (acceptedPrice ?? 0) > 0;

  /// Whether an offer can be sent right now: the API allows it, none is in
  /// flight or approved, and at least one attempt is left today.
  bool get canOffer =>
      canSubmit && attemptsLeft > 0 && !isPending && !isApproved;

  @override
  List<Object?> get props => [
    variantKey,
    sizeId,
    colorId,
    listedPrice,
    status,
    attemptsUsed,
    dailyLimit,
    offeredPrice,
    counteredPrice,
    suggestedPrice,
    acceptedPrice,
    minimumOffer,
    minimumOfferPercent,
    expiresAt,
    canSubmit,
  ];
}
