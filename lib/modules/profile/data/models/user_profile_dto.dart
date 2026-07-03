import '../../domain/entities/user_profile.dart';

/// Parses `GET /api/profile` (and the `POST /api/update-profile` response,
/// which presumably echoes the saved profile) into a [UserProfile].
///
/// PROVISIONAL: no sample response was available when this was written —
/// field names mirror `POST /api/update-profile`'s own request body (name,
/// phone, country_iso, country_code, email, profile_photo, gender,
/// date_of_birth). Reconcile `_K` and the envelope-unwrap keys against the
/// real payload — only this file should need editing.
class UserProfileDto {
  const UserProfileDto._();

  static UserProfile fromJson(Object? data) {
    final json = _asMap(data);
    return UserProfile(
      name: _str(json[_K.name]),
      email: _str(json[_K.email]),
      phone: _str(json[_K.phone]),
      countryIso: _orDefault(_str(json[_K.countryIso]), 'KW'),
      countryCode: _orDefault(_str(json[_K.countryCode]), '965'),
      profilePhoto: _str(json[_K.profilePhoto]),
      gender: json[_K.gender] as String?,
      dateOfBirth: json[_K.dateOfBirth] as String?,
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

class _K {
  static const name = 'name';
  static const email = 'email';
  static const phone = 'phone';
  static const countryIso = 'country_iso';
  static const countryCode = 'country_code';
  static const profilePhoto = 'profile_photo';
  static const gender = 'gender';
  static const dateOfBirth = 'date_of_birth';
}
