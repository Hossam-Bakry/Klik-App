import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/repositories/security_repository.dart';

part 'security_state.dart';

/// Page-scoped Cubit for the Security page — a single "delete account"
/// action. Does not touch the session itself; the page dispatches
/// `AuthLogoutRequested` on success so the local session is cleared and the
/// router drops back to the guest experience.
class SecurityCubit extends Cubit<SecurityState> {
  SecurityCubit(this._repository) : super(const SecurityState());

  final SecurityRepository _repository;

  Future<void> deleteAccount() async {
    emit(state.copyWith(
      status: SecurityStatus.deleting,
      clearError: true,
    ));
    final result = await _repository.deleteAccount();
    switch (result) {
      case ApiSuccess():
        emit(state.copyWith(status: SecurityStatus.deleted));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: SecurityStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
