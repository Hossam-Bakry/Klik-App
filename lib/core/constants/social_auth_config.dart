/// OAuth client IDs for Google Sign-In.
///
/// Fill these from Google Cloud Console (OAuth 2.0 Client IDs):
///   - [googleServerClientId]: the **Web** client ID — required on Android (and
///     to get a server auth token the backend can verify).
///   - [googleIosClientId]: the **iOS** client ID — alternatively set `GIDClientID`
///     in ios/Runner/Info.plist and leave this null.
///
/// Leave a value null to fall back to the platform's native config
/// (google-services.json on Android / Info.plist on iOS).
class SocialAuthConfig {
  const SocialAuthConfig._();

  // TODO: set these from your Google Cloud OAuth client IDs.
  static const String googleIosClientId = "378934524870-j9gtun2i8lf5smru0fd3g4q02mkbsld7.apps.googleusercontent.com";
  static const String googleServerClientId = "378934524870-960i6q90fgop012bl0jovqm4jtiijlh9.apps.googleusercontent.com";
}
