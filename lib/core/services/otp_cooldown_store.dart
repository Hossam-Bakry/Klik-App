import 'package:shared_preferences/shared_preferences.dart';

/// Persists the "last OTP sent" moment per phone so the resend cooldown can't
/// be bypassed by leaving and re-entering the verification screen — or even by
/// restarting the app. Backed by [SharedPreferences] (epoch millis per phone).
class OtpCooldownStore {
  OtpCooldownStore(this._prefs);

  final SharedPreferences _prefs;

  /// Seconds the user must wait between OTP requests.
  static const int cooldownSeconds = 40;

  static const String _prefix = 'otp_sent_at_';

  String _key(String phone) => '$_prefix$phone';

  /// Record that an OTP was just sent to [phone].
  Future<void> markSent(String phone) =>
      _prefs.setInt(_key(phone), DateTime.now().millisecondsSinceEpoch);

  /// Seconds left before another OTP may be requested for [phone] (0 = ready).
  int remainingSeconds(String phone) {
    final sentAt = _prefs.getInt(_key(phone));
    if (sentAt == null) return 0;
    final elapsed =
        (DateTime.now().millisecondsSinceEpoch - sentAt) ~/ 1000;
    final left = cooldownSeconds - elapsed;
    return left < 0 ? 0 : left;
  }

  /// Whether a new OTP can be requested for [phone] right now.
  bool canRequest(String phone) => remainingSeconds(phone) == 0;
}
