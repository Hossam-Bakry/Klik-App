import 'package:dio/dio.dart';

import '../api_constants.dart';
import '../token_provider.dart';

/// Adds `Authorization: Bearer <token>` to every request when a token exists.
/// Public endpoints (login, register, send-otp, …) simply have no token before
/// sign-in, so nothing is attached — no per-request opt-out needed.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenProvider);

  final TokenProvider _tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Allow a request to explicitly skip auth via `extra['skipAuth'] = true`.
    final skip = options.extra['skipAuth'] == true;
    if (!skip) {
      final token = await _tokenProvider();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.headerAuthorization] =
            '${ApiConstants.bearerPrefix}$token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: on 401, trigger sign-out / token refresh. Hooking this to AuthBloc
    // requires a callback or event bus — wire it when refresh tokens exist.
    handler.next(err);
  }
}
