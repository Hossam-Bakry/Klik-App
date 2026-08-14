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

/// The phone awaiting OTP activation — captured at registration, or at a login
/// that turned out to be an unverified account. The resend cooldown lives in
/// the persistent [OtpCooldownStore] (keyed by phone), not here, so it survives
/// leaving/reopening the screen.
class PendingPhoneVerification extends Equatable {
  const PendingPhoneVerification({
    required this.phone,
    required this.countryIso,
    required this.countryCode,
    required this.password,
  });

  final String phone;
  final String countryIso;
  final String countryCode;

  /// The password the user just typed. `verify-phone-otp` activates the account
  /// but issues no token, so the bloc signs in with this the moment the OTP is
  /// accepted. Held in memory for the length of the flow only — never persisted.
  final String password;

  /// Deliberately excludes [password]: the phone already identifies the flow,
  /// and props are what a BlocObserver prints in debug builds.
  @override
  List<Object?> get props => [phone, countryIso, countryCode];
}
