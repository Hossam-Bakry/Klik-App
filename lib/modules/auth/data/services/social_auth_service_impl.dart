import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/constants/social_auth_config.dart';
import '../../domain/entities/social_account.dart';
import '../../domain/services/social_auth_service.dart';

/// [SocialAuthService] backed by the native Google (v7) and Apple SDKs.
/// Returns null on user cancellation; rethrows real errors for the repository
/// to map into a [Failure].
class SocialAuthServiceImpl implements SocialAuthService {
  bool _googleInitialized = false;

  @override
  Future<SocialAccount?> signIn(SocialAuthType type) {
    return switch (type) {
      SocialAuthType.google => _google(),
      SocialAuthType.apple => _apple(),
    };
  }

  Future<SocialAccount?> _google() async {
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize(
        clientId: SocialAuthConfig.googleIosClientId,
        serverClientId: SocialAuthConfig.googleServerClientId,
      );
      _googleInitialized = true;
    }

    try {
      final account = await google.authenticate(scopeHint: const ['email']);
      return SocialAccount(
        type: SocialAuthType.google,
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  Future<SocialAccount?> _apple() async {
    try {
      final cred = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      // Name/email are only returned on the FIRST authorization — the backend
      // should persist them then. userIdentifier is the stable Apple `sub`.
      final name = [cred.givenName, cred.familyName]
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .join(' ');
      return SocialAccount(
        type: SocialAuthType.apple,
        id: cred.userIdentifier ?? '',
        name: name,
        email: cred.email ?? '',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}
