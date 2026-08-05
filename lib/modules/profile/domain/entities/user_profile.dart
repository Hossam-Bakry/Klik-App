import 'package:equatable/equatable.dart';

/// The signed-in user's profile (`GET /api/profile`, `POST
/// /api/update-profile`).
class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.countryIso,
    required this.countryCode,
    this.id = 0,
    this.profilePhoto = '',
    this.country = '',
    this.gender,
    this.dateOfBirth,
    this.phoneVerified = false,
    this.emailVerified = false,
  });

  /// Account id. `0` when the payload carried none.
  final int id;

  final String name;
  final String email;

  /// National number only (no dial code) — paired with [countryCode].
  final String phone;

  /// ISO country code, e.g. "KW". Defaults to Kuwait when the account has none.
  final String countryIso;

  /// Dial code, e.g. "965" — read from `country_code`, falling back to
  /// `phone_code`.
  final String countryCode;

  /// Country name as the API spells it, e.g. "Egypt". Display-only.
  final String country;

  /// An already-hosted image URL. Uploading a new one goes through
  /// `update-profile` as multipart — see the Edit Profile page.
  final String profilePhoto;
  final String? gender;

  /// ISO 8601 date (e.g. "1995-06-15"), as the API sends/expects it.
  final String? dateOfBirth;

  final bool phoneVerified;
  final bool emailVerified;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? countryIso,
    String? countryCode,
    String? profilePhoto,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryIso: countryIso ?? this.countryIso,
      countryCode: countryCode ?? this.countryCode,
      country: country,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender,
      dateOfBirth: dateOfBirth,
      phoneVerified: phoneVerified,
      emailVerified: emailVerified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    countryIso,
    countryCode,
    country,
    profilePhoto,
    gender,
    dateOfBirth,
    phoneVerified,
    emailVerified,
  ];
}
