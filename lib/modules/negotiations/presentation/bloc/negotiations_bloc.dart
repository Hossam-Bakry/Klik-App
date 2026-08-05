import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/negotiation.dart';
import '../../domain/entities/negotiation_board.dart';
import '../../domain/repositories/negotiations_repository.dart';

part 'negotiations_event.dart';
part 'negotiations_state.dart';

/// Loads the customer's offers for the "My Negotiations" screen. The API
/// returns every status bucket in one call, so switching chips is a local
/// filter ([NegotiationsFilterChanged]) rather than another request.
class NegotiationsBloc extends Bloc<NegotiationsEvent, NegotiationsState> {
  NegotiationsBloc(this._repository) : super(const NegotiationsState()) {
    on<NegotiationsStarted>(_onStarted);
    on<NegotiationsRefreshed>(_onRefreshed);
    on<NegotiationsFilterChanged>(_onFilterChanged);
  }

  final NegotiationsRepository _repository;

  Future<void> _onStarted(
    NegotiationsStarted event,
    Emitter<NegotiationsState> emit,
  ) async {
    emit(state.copyWith(status: NegotiationsStatus.loading));
    await _load(emit);
  }

  /// Pull-to-refresh — re-fetches without dropping back to the skeleton.
  Future<void> _onRefreshed(
    NegotiationsRefreshed event,
    Emitter<NegotiationsState> emit,
  ) async {
    await _load(emit);
  }

  void _onFilterChanged(
    NegotiationsFilterChanged event,
    Emitter<NegotiationsState> emit,
  ) {
    emit(state.copyWith(filter: event.filter, clearFilter: event.filter == null));
  }

  Future<void> _load(Emitter<NegotiationsState> emit) async {
    final result = await _repository.fetchNegotiations();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: NegotiationsStatus.success, board: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: NegotiationsStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
