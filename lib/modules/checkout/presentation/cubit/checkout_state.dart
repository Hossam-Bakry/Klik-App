part of 'checkout_cubit.dart';

/// The three steps in the header, in order.
enum CheckoutStep { address, payment, review }

enum CheckoutStatus { initial, loading, ready, placing, placed }

enum CouponStatus { none, applying, applied, rejected }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.step = CheckoutStep.address,
    this.summary = CheckoutSummary.empty,
    this.method = PaymentMethod.cash,
    this.cardLabel = '',
    this.couponStatus = CouponStatus.none,
    this.couponCode = '',
    this.couponDiscount = 0,
    this.errorMessage,
  });

  final CheckoutStatus status;
  final CheckoutStep step;

  /// What the server says the cart comes to, before the cart's own fallback.
  final CheckoutSummary summary;

  final PaymentMethod method;

  /// Masked card number, e.g. "•••• 4242" — display only.
  final String cardLabel;

  final CouponStatus couponStatus;
  final String couponCode;
  final double couponDiscount;

  final String? errorMessage;

  bool get isLoading =>
      status == CheckoutStatus.initial || status == CheckoutStatus.loading;

  bool get isPlacing => status == CheckoutStatus.placing;

  bool get hasCoupon => couponStatus == CouponStatus.applied;

  /// The summary with the cart's own figures filling whatever the endpoint
  /// left at zero, plus any coupon applied here.
  CheckoutSummary totalsFor(double cartTotal) => summary.resolvedAgainst(
    cartTotal: cartTotal,
    couponDiscount: hasCoupon ? couponDiscount : null,
  );

  CheckoutState copyWith({
    CheckoutStatus? status,
    CheckoutStep? step,
    CheckoutSummary? summary,
    PaymentMethod? method,
    String? cardLabel,
    CouponStatus? couponStatus,
    String? couponCode,
    double? couponDiscount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      step: step ?? this.step,
      summary: summary ?? this.summary,
      method: method ?? this.method,
      cardLabel: cardLabel ?? this.cardLabel,
      couponStatus: couponStatus ?? this.couponStatus,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    step,
    summary,
    method,
    cardLabel,
    couponStatus,
    couponCode,
    couponDiscount,
    errorMessage,
  ];
}
