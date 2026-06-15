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

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
