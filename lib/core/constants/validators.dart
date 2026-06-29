import 'package:flutter/material.dart';

import '../extensions/localization_extension.dart';
import '../localization/locale_keys.dart';
import 'countries.dart';

/// Central home for every form-field validator in the app.
///
/// Each method returns a `String? Function(String?)` ready to hand to a
/// [TextFormField]/[Form] validator, and resolves its message through
/// [BuildContext.tr] so errors stay localized. The rules mirror the backend
/// "Customer Authentication API Validation Rules" so the client rejects the
/// same input the API would.
///
/// Add a new rule here rather than inlining `(v) => ...` at call sites, so the
/// regexes and limits live in one place.
abstract class Validators {
  const Validators._();

  /// Allowed special characters for [strongPassword] — matches the backend
  /// StrongPassword rule (`@$!%*?&`).
  static const passwordSpecialChars = r'@$!%*?&';

  /// Upper bound on password length. Enforced both at input time (via a
  /// [LengthLimitingTextInputFormatter] in `AppTextField.password`) and in
  /// [strongPassword] so an oversized payload can never reach the API.
  static const passwordMaxLength = 64;

  /// Strong password: min 6 chars with at least one lowercase, uppercase,
  /// digit, and special character from [passwordSpecialChars].
  static final RegExp _strongPassword = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[' +
        passwordSpecialChars +
        r'])[A-Za-z\d' +
        passwordSpecialChars +
        r']{6,}$',
  );

  static final RegExp _email = RegExp(
    r'^[\w.+-]+@[\w-]+\.[\w.-]+$',
  );

  /// Letters (any script, so Arabic and Latin both pass) and spaces only —
  /// no digits or special characters. Used by [name].
  static final RegExp _name = RegExp(r'^[\p{L} ]+$', unicode: true);

  /// Minimum and maximum length for [name].
  static const nameMinLength = 2;
  static const nameMaxLength = 20;

  /// Required, non-empty (after trimming).
  static String? Function(String?) required(BuildContext context) =>
      (value) => (value == null || value.trim().isEmpty)
          ? context.tr(LocaleKeys.fieldRequired)
          : null;

  /// Required; letters and spaces only (no digits or special characters);
  /// between [nameMinLength] and [nameMaxLength] characters.
  static String? Function(String?) name(BuildContext context) => (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return context.tr(LocaleKeys.fieldRequired);
        if (text.length < nameMinLength) {
          return context.tr(LocaleKeys.nameMin);
        }
        if (text.length > nameMaxLength) return context.tr(LocaleKeys.nameMax);
        if (!_name.hasMatch(text)) return context.tr(LocaleKeys.nameInvalid);
        return null;
      };

  /// Required, valid email format.
  static String? Function(String?) email(BuildContext context) => (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return context.tr(LocaleKeys.fieldRequired);
        if (!_email.hasMatch(text)) return context.tr(LocaleKeys.invalidEmail);
        return null;
      };

  /// Phone number for the selected [country]: required, digits only, must not
  /// start with `0`, and exactly the country's national length.
  static String? Function(String?) phone(
    BuildContext context,
    Country country,
  ) =>
      (value) {
        final digits = value?.trim() ?? '';
        if (digits.isEmpty) return context.tr(LocaleKeys.fieldRequired);
        if (digits.startsWith('0')) {
          return context.tr(LocaleKeys.phoneNoLeadingZero);
        }
        if (!country.isValidPhone(digits)) {
          return context.tr(LocaleKeys.invalidPhone);
        }
        return null;
      };

  /// Strong password per the backend StrongPassword rule.
  static String? Function(String?) strongPassword(BuildContext context) =>
      (value) {
        final text = value ?? '';
        if (text.isEmpty) return context.tr(LocaleKeys.fieldRequired);
        if (text.length > passwordMaxLength) {
          return context.tr(LocaleKeys.passwordMax);
        }
        if (!_strongPassword.hasMatch(text)) {
          return context.tr(LocaleKeys.passwordStrong);
        }
        return null;
      };

  /// Confirmation field: must match the [original] password input.
  static String? Function(String?) confirmPassword(
    BuildContext context,
    TextEditingController original,
  ) =>
      (value) => (value != original.text)
          ? context.tr(LocaleKeys.passwordsDoNotMatch)
          : null;
}
