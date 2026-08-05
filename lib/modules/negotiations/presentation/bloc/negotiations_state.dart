part of 'negotiations_bloc.dart';

enum NegotiationsStatus { initial, loading, success, failure }

class NegotiationsState extends Equatable {
  const NegotiationsState({
    this.status = NegotiationsStatus.initial,
    this.board = const NegotiationBoard(),
    this.filter,
    this.errorMessage,
  });

  final NegotiationsStatus status;

  /// Every bucket the API returned, plus its chip counts.
  final NegotiationBoard board;

  /// The selected chip; `null` is "All".
  final NegotiationStatus? filter;

  final String? errorMessage;

  bool get isLoading =>
      status == NegotiationsStatus.initial ||
      status == NegotiationsStatus.loading;

  /// The rows the list should render for the current chip.
  List<Negotiation> get visible => board.of(filter);

  NegotiationsState copyWith({
    NegotiationsStatus? status,
    NegotiationBoard? board,
    NegotiationStatus? filter,
    bool clearFilter = false,
    String? errorMessage,
  }) {
    return NegotiationsState(
      status: status ?? this.status,
      board: board ?? this.board,
      // `filter` is nullable, so "back to All" needs its own flag.
      filter: clearFilter ? null : (filter ?? this.filter),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, board, filter, errorMessage];
}
