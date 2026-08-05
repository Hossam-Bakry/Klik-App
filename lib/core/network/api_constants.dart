/// Network configuration derived from the Postman collection (Klik Copy).
///
/// Base URL, common headers, and the response envelope are documented here so
/// every request stays consistent with the backend contract.
///
/// Common headers (JSON APIs):
///   - Accept: application/json
///   - Content-Type: application/json   (on POST/PUT/PATCH with a JSON body)
///   - accept-language: en              (drives server-side validation messages)
///   - `Authorization: Bearer <token>`  (Sanctum; added by [AuthInterceptor])
///
/// Response envelope: most controllers return `{ "message": "...", "data": {...} }`
/// — DioApiClient unwraps this and returns an `ApiResult`.
class ApiConstants {
  const ApiConstants._();

  /// Postman `{{base_url}}`. Override per environment via --dart-define when
  /// you wire flavors (e.g. staging/production).
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://tryklik.net',
  );

  // ---- Header names ----
  static const String headerAccept = 'Accept';
  static const String headerContentType = 'Content-Type';
  static const String headerAcceptLanguage = 'accept-language';
  static const String headerAuthorization = 'Authorization';
  // PROVISIONAL: guest cart identifier header; confirm the name with the backend.
  static const String headerGuestToken = 'X-Guest-Token';

  // ---- Header values ----
  static const String applicationJson = 'application/json';
  static const String bearerPrefix = 'Bearer ';

  /// Default locale for `accept-language`. Swap to 'ar' for Arabic. Make this
  /// dynamic (read from the app's locale) once localization is wired.
  static const String defaultLanguage = 'en';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
