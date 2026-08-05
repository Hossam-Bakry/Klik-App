part of 'negotiations_bloc.dart';

sealed class NegotiationsEvent extends Equatable {
  const NegotiationsEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the customer's offers.
class NegotiationsStarted extends NegotiationsEvent {
  const NegotiationsStarted();
}

/// Pull-to-refresh — re-fetches without the full-screen loader.
class NegotiationsRefreshed extends NegotiationsEvent {
  const NegotiationsRefreshed();
}

/// Tapped a filter chip. `null` is the "All" chip.
class NegotiationsFilterChanged extends NegotiationsEvent {
  const NegotiationsFilterChanged(this.filter);

  final NegotiationStatus? filter;

  @override
  List<Object?> get props => [filter];
}
