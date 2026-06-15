import '../entities/social_account.dart';

/// Performs the native (provider-side) social sign-in. Returns the resulting
/// [SocialAccount], or `null` if the user cancelled. Throws on a real error.
abstract interface class SocialAuthService {
  Future<SocialAccount?> signIn(SocialAuthType type);
}
