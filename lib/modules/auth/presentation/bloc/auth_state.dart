part of 'auth_bloc.dart';

/// [unknown] is the bootstrap state before the persisted session is read —
/// the router keeps the user on splash until this resolves.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;

  /// True while a login request is in flight (drives the button spinner).
  final bool isSubmitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, isSubmitting, errorMessage];
}
