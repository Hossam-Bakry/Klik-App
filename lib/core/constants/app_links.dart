/// Public web pages the app links out to.
///
/// These live on the marketing site rather than the API, so they're plain URLs
/// with no endpoint behind them — the app opens them in a browser view instead
/// of rendering the content itself.
class AppLinks {
  const AppLinks._();

  /// Both were supplied by the team on 2026-08-07 and answer 200 on the `www`
  /// host — keep the prefix, the apex host isn't guaranteed to serve them.
  static const String privacyPolicy = 'https://www.tryklik.net/privacy-policy';
  static const String termsAndConditions =
      'https://www.tryklik.net/terms-and-conditions';

  /// What "Sell With Us" shares. Swap in the App Store / Play Store listings
  /// once the app is published — a store link is what an invitation wants.
  static const String website = 'https://www.tryklik.net';
}
