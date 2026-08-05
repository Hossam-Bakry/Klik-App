import '../../domain/entities/user_profile.dart';

/// Parses `GET /api/profile` (and the `POST /api/update-profile` response,
/// which echoes the saved profile) into a [UserProfile].
///
/// The payload wraps the fields under `user`:
/// `{ id, name, phone, phone_verified, email, email_verified, is_active,
///    profile_photo, gender, date_of_birth, country, country_iso, phone_code,
///    country_code, account_verified }`.
class UserProfileDto {
  const UserProfileDto._();

  static UserProfile fromJson(Object? data) {
    final json = _asMap(data);
    return UserProfile(
      id: _toInt(json[_K.id]),
      name: _str(json[_K.name]),
      email: _str(json[_K.email]),
      phone: _str(json[_K.phone]),
      countryIso: _orDefault(_str(json[_K.countryIso]), 'KW'),
      // Both `country_code` and `phone_code` are sent, and either may be null
      // on an account that never set one.
      countryCode: _orDefault(
        _orDefault(_str(json[_K.countryCode]), _str(json[_K.phoneCode])),
        '965',
      ),
      country: _str(json[_K.country]),
      profilePhoto: _str(json[_K.profilePhoto]),
      gender: json[_K.gender] as String?,
      dateOfBirth: json[_K.dateOfBirth] as String?,
      phoneVerified: _toBool(json[_K.phoneVerified]),
      emailVerified: _toBool(json[_K.emailVerified]),
    );
  }

  /// Accepts a bare object or one wrapped under `user`/`profile`.
  static Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) {
      for (final key in const ['user', 'profile']) {
        final inner = data[key];
        if (inner is Map<String, dynamic>) return inner;
      }
      return data;
    }
    return const {};
  }
}

String _str(Object? v) => v?.toString().trim() ?? '';

String _orDefault(String value, String fallback) =>
    value.isEmpty ? fallback : value;

int _toInt(Object? v) => switch (v) {
  num n => n.toInt(),
  String s => int.tryParse(s) ?? 0,
  _ => 0,
};

bool _toBool(Object? v) =>
    v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';

class _K {
  static const id = 'id';
  static const name = 'name';
  static const email = 'email';
  static const phone = 'phone';
  static const phoneVerified = 'phone_verified';
  static const emailVerified = 'email_verified';
  static const country = 'country';
  static const countryIso = 'country_iso';
  static const countryCode = 'country_code';
  static const phoneCode = 'phone_code';
  static const profilePhoto = 'profile_photo';
  static const gender = 'gender';
  static const dateOfBirth = 'date_of_birth';
}
