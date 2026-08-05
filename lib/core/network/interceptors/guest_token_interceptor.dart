import 'package:dio/dio.dart';

import '../api_constants.dart';
import '../token_provider.dart';

/// Attaches `X-Guest-Token` so the backend can key an anonymous (guest) cart to
/// this device. Only added when the request isn't already authenticated — once
/// a bearer token is present the cart is owned by the account, not the guest
/// token. Must run *after* [AuthInterceptor] so the Authorization check is
/// meaningful.
///
/// PROVISIONAL: the header name is assumed; confirm it against the backend.
class GuestTokenInterceptor extends Interceptor {
  GuestTokenInterceptor(this._guestTokenProvider);

  final GuestTokenProvider _guestTokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final isAuthenticated =
        options.headers.containsKey(ApiConstants.headerAuthorization);
    if (!isAuthenticated) {
      final guestToken = _guestTokenProvider();
      if (guestToken != null && guestToken.isNotEmpty) {
        options.headers[ApiConstants.headerGuestToken] = guestToken;
      }
    }
    handler.next(options);
  }
}
