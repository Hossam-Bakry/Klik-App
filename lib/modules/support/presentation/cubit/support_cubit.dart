import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/repositories/support_repository.dart';

part 'support_state.dart';

/// Page-scoped Cubit for the Support form — a single "submit" action, no list
/// state. The mockup's form has no subject field, so [submit] sends a fixed
/// [_defaultSubject] the backend can use to route/label the ticket.
class SupportCubit extends Cubit<SupportState> {
  SupportCubit(this._repository) : super(const SupportState());

  final SupportRepository _repository;

  static const _defaultSubject = 'Support request';

  Future<void> submit({
    required String name,
    required String phone,
    required String message,
  }) async {
    emit(state.copyWith(status: SupportStatus.submitting, clearError: true));
    final result = await _repository.submit(
      name: name,
      phone: phone,
      subject: _defaultSubject,
      message: message,
    );
    switch (result) {
      case ApiSuccess():
        emit(state.copyWith(status: SupportStatus.success));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: SupportStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
