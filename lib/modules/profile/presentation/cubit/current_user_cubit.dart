import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'current_user_state.dart';

/// App-wide holder for the signed-in user's profile (`GET /api/profile`),
/// shared like `CartCountCubit` so the Profile header — and anything else that
/// needs the account's name/photo — reads one source.
///
/// `main.dart` drives its lifecycle off [AuthStatus]: [load] on sign-in,
/// [clear] on sign-out. Guests never hold a profile.
class CurrentUserCubit extends Cubit<CurrentUserState> {
  CurrentUserCubit(this._repository) : super(const CurrentUserState());

  final ProfileRepository _repository;

  Future<void> load() async {
    // Keep any profile already on screen while refreshing — only a first load
    // shows the header's skeleton.
    emit(state.copyWith(status: CurrentUserStatus.loading));
    final result = await _repository.getProfile();
    switch (result) {
      case ApiSuccess(:final data):
        emit(CurrentUserState(
          status: CurrentUserStatus.loaded,
          profile: data,
        ));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: CurrentUserStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  /// Adopt a profile the app already has — the Edit Profile screen calls this
  /// after a successful save so the header updates without another round trip.
  void set(UserProfile profile) => emit(
    CurrentUserState(status: CurrentUserStatus.loaded, profile: profile),
  );

  /// Drop the profile on sign-out so the next session starts clean.
  void clear() => emit(const CurrentUserState());
}
