part of 'current_user_cubit.dart';

enum CurrentUserStatus { initial, loading, loaded, failure }

class CurrentUserState extends Equatable {
  const CurrentUserState({
    this.status = CurrentUserStatus.initial,
    this.profile,
    this.errorMessage,
  });

  final CurrentUserStatus status;

  /// Null until the first successful load, and again after sign-out.
  final UserProfile? profile;

  final String? errorMessage;

  /// Nothing to show yet — the header renders its skeleton.
  bool get isLoading =>
      profile == null &&
      (status == CurrentUserStatus.initial ||
          status == CurrentUserStatus.loading);

  CurrentUserState copyWith({
    CurrentUserStatus? status,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return CurrentUserState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
