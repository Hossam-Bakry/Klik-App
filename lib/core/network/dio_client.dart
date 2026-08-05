import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/common_headers_interceptor.dart';
import 'interceptors/guest_token_interceptor.dart';
import 'token_provider.dart';

/// Builds the app-wide [Dio] instance with the shared base options and the
/// common-headers + auth + guest-token interceptors (order matters: headers
/// first, then auth, then guest token — which skips itself when authenticated —
/// then logging).
class DioClient {
  DioClient(
    TokenProvider tokenProvider, {
    String Function()? languageProvider,
    GuestTokenProvider? guestTokenProvider,
  }) : dio = _build(tokenProvider, languageProvider, guestTokenProvider);

  final Dio dio;

  static Dio _build(
    TokenProvider tokenProvider,
    String Function()? languageProvider,
    GuestTokenProvider? guestTokenProvider,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.addAll([
      CommonHeadersInterceptor(languageProvider: languageProvider),
      AuthInterceptor(tokenProvider),
      if (guestTokenProvider != null)
        GuestTokenInterceptor(guestTokenProvider),
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          assert(() {
            // ignore: avoid_print
            print(obj);
            return true;
          }());
        },
      ),
    ]);

    return dio;
  }
}
