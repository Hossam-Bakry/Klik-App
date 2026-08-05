import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// The *entire* local footprint of a guest's cart: a stable token that
/// identifies the cart on the backend, plus a cached item count for the
/// bottom-nav badge. The cart's actual contents (items, prices, sizes) live on
/// the server keyed by [token] and are never cached here — the client fetches
/// them live when the cart screen opens.
///
/// Backed by [SharedPreferences] so the interceptor can read [token]
/// synchronously on every request, and so both values survive an app restart.
class GuestCartStore {
  GuestCartStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _tokenKey = 'guest_cart_token';
  static const String _countKey = 'guest_cart_count';

  /// The current guest cart token, or null before the guest's first add.
  String? get token => _prefs.getString(_tokenKey);

  /// Cached badge count (0 when no guest cart exists yet).
  int get count => _prefs.getInt(_countKey) ?? 0;

  /// Returns the existing guest token, generating and persisting one on the
  /// first call. Call this right before the first add-to-cart request so the
  /// [GuestTokenInterceptor] has a token to attach.
  Future<String> ensureToken() async {
    final existing = _prefs.getString(_tokenKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _generateToken();
    await _prefs.setString(_tokenKey, generated);
    return generated;
  }

  Future<void> setCount(int value) =>
      _prefs.setInt(_countKey, value < 0 ? 0 : value);

  /// Wipes the guest cart's local footprint. Called once the guest cart has been
  /// merged into a real account so the token is never reused after sign-in.
  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_countKey);
  }

  /// UUID v4 built with [Random.secure] so we avoid pulling in a package (the
  /// project's build hook is fragile — see the FlutterGen note). The value is
  /// opaque to us; the backend just echoes it back to key the guest cart.
  static String _generateToken() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 1
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
