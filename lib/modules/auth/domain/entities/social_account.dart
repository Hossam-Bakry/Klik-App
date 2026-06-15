/// Which social provider a sign-in came from. `name` is sent as `auth_type`.
enum SocialAuthType { google, apple }

/// The profile returned by a native social sign-in, mapped to the
/// `POST /api/social-auth` payload.
class SocialAccount {
  const SocialAccount({
    required this.type,
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final SocialAuthType type;

  /// Google user id, or Apple `sub` (userIdentifier).
  final String id;
  final String name;
  final String email;

  /// Google photo URL → `profile_url`. Apple does not provide one.
  final String? photoUrl;

  Map<String, dynamic> toJson() => {
        'auth_type': type.name,
        'id': id,
        'name': name,
        'email': email,
        if (photoUrl != null && photoUrl!.isNotEmpty) 'profile_url': photoUrl,
      };
}
