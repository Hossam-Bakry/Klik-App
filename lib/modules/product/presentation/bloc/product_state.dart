part of 'product_bloc.dart';

enum ProductStatus { initial, loading, success, failure }

/// Lifecycle of a `POST /api/bid` call, kept apart from [ProductStatus] so
/// sending an offer never drops the page back into its loading skeleton.
enum BidSubmissionStatus { idle, submitting, success, failure }

/// Single state object with a [status] enum (same pattern as HomeBloc). The UI
/// switches on [status] and reads [product]/[errorMessage] as needed.
class ProductState extends Equatable {
  const ProductState({
    this.status = ProductStatus.initial,
    this.product,
    this.errorMessage,
    this.bidStatus = BidSubmissionStatus.idle,
    this.bidMessage,
  });

  final ProductStatus status;
  final ProductDetails? product;
  final String? errorMessage;

  /// How far the last offer submission got — the page toasts the outcome.
  final BidSubmissionStatus bidStatus;

  /// Server message for that submission (success or failure).
  final String? bidMessage;

  bool get isLoading =>
      status == ProductStatus.initial || status == ProductStatus.loading;

  bool get isSubmittingBid => bidStatus == BidSubmissionStatus.submitting;

  ProductState copyWith({
    ProductStatus? status,
    ProductDetails? product,
    String? errorMessage,
    BidSubmissionStatus? bidStatus,
    String? bidMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage,
      bidStatus: bidStatus ?? this.bidStatus,
      bidMessage: bidMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    product,
    errorMessage,
    bidStatus,
    bidMessage,
  ];
}
