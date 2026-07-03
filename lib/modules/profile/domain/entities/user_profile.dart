import 'package:equatable/equatable.dart';

/// The signed-in user's editable profile fields (`GET`/`POST
/// /api/[update-]profile`).
class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.countryIso,
    required this.countryCode,
    this.profilePhoto = '',
    this.gender,
    this.dateOfBirth,
  });

  final String name;
  final String email;

  /// National number only (no dial code) — paired with [countryCode].
  final String phone;
  final String countryIso;
  final String countryCode;

  /// An already-hosted image URL. No upload endpoint exists yet — see the
  /// Edit Profile page's "Change Photo" action.
  final String profilePhoto;
  final String? gender;

  /// ISO 8601 date (e.g. "1995-06-15"), as the API sends/expects it.
  final String? dateOfBirth;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? countryIso,
    String? countryCode,
    String? profilePhoto,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      countryIso: countryIso ?? this.countryIso,
      countryCode: countryCode ?? this.countryCode,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    countryIso,
    countryCode,
    profilePhoto,
    gender,
    dateOfBirth,
  ];
}
