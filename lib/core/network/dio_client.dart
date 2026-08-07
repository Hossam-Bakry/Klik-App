import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/common_headers_interceptor.dart';
import 'token_provider.dart';

/// Builds the app-wide [Dio] instance with the shared base options and the
/// common-headers + auth interceptors (order matters: headers first, then auth,
/// then logging).
class DioClient {
  DioClient(
    TokenProvider tokenProvider, {
    String Function()? languageProvider,
  }) : dio = _build(tokenProvider, languageProvider);

  final Dio dio;

  static Dio _build(
    TokenProvider tokenProvider,
    String Function()? languageProvider,
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
