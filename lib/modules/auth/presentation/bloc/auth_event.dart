part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once at app start to resolve the persisted session.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.phone,
    required this.password,
    required this.countryIso,
    required this.countryCode,
  });

  final String phone;
  final String password;
  final String countryIso;
  final String countryCode;

  @override
  List<Object?> get props => [phone, password, countryIso, countryCode];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.country,
    required this.countryIso,
    required this.countryCode,
    this.gender,
  });

  final String name;
  final String email;
  final String password;
  final String phone;
  final String country;
  final String countryIso;
  final String countryCode;
  final String? gender;

  @override
  List<Object?> get props =>
      [name, email, password, phone, country, countryIso, countryCode, gender];
}

class AuthSocialSignInRequested extends AuthEvent {
  const AuthSocialSignInRequested(this.type);

  final SocialAuthType type;

  @override
  List<Object?> get props => [type];
}

/// Submits the registration OTP to verify the phone and activate the account.
/// Uses the phone captured in [AuthState.pendingVerification].
class AuthPhoneOtpSubmitted extends AuthEvent {
  const AuthPhoneOtpSubmitted(this.otp);

  final String otp;

  @override
  List<Object?> get props => [otp];
}

/// Requests an activation OTP for the pending phone — sent on the verify
/// screen's open and on the explicit resend tap. Honors the per-phone cooldown:
/// if a code was sent to this same number recently it is skipped (the live one
/// is reused); a different number always sends.
class AuthPhoneOtpRequested extends AuthEvent {
  const AuthPhoneOtpRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
