part of 'auth_bloc.dart';

/// [unknown] is the bootstrap state before the persisted session is read —
/// the router keeps the user on splash until this resolves.
///
/// [unauthenticated] is the **guest** state: the user can browse the app, but
/// account features (cart, negotiation, addresses, profile actions) are gated
/// and prompt sign-in. [authenticated] unlocks everything.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.isSubmitting = false,
    this.errorMessage,
    this.pendingVerification,
  });

  final AuthStatus status;
  final AuthSession? session;

  /// True while a login request is in flight (drives the button spinner).
  final bool isSubmitting;
  final String? errorMessage;

  /// Set after a successful registration: the phone awaiting OTP verification.
  /// Drives navigation to the verify-phone screen and is cleared once the
  /// account is activated (authenticated) or the flow is abandoned.
  final PendingPhoneVerification? pendingVerification;

  /// Signed in with a real session — unlocks gated account features.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Browsing without an account. Gated features prompt sign-in.
  bool get isGuest => status == AuthStatus.unauthenticated;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool? isSubmitting,
    String? errorMessage,
    PendingPhoneVerification? pendingVerification,
    bool clearPendingVerification = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      pendingVerification: clearPendingVerification
          ? null
          : (pendingVerification ?? this.pendingVerification),
    );
  }

  @override
  List<Object?> get props =>
      [status, session, isSubmitting, errorMessage, pendingVerification];
}

/// The phone captured at registration that must be OTP-verified to activate
/// the account.
class PendingPhoneVerification extends Equatable {
  const PendingPhoneVerification({
    required this.phone,
    required this.countryIso,
    required this.countryCode,
  });

  final String phone;
  final String countryIso;
  final String countryCode;

  @override
  List<Object?> get props => [phone, countryIso, countryCode];
}
