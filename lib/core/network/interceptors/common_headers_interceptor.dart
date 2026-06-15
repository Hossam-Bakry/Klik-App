import 'package:dio/dio.dart';

import '../api_constants.dart';

/// Attaches the headers every JSON API request shares (per the Postman
/// collection): `Accept`, `Content-Type`, and `accept-language`.
///
/// [languageProvider] is read on every request so the locale stays in sync
/// with the app's current language (e.g. driven by LocaleCubit). Falls back to
/// [ApiConstants.defaultLanguage].
class CommonHeadersInterceptor extends Interceptor {
  CommonHeadersInterceptor({String Function()? languageProvider})
      : _languageProvider = languageProvider;

  final String Function()? _languageProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers[ApiConstants.headerAccept] = ApiConstants.applicationJson;
    options.headers[ApiConstants.headerAcceptLanguage] =
        _languageProvider?.call() ?? ApiConstants.defaultLanguage;
    // Only declare a JSON body type when there actually is a body.
    if (options.data != null) {
      options.headers[ApiConstants.headerContentType] =
          ApiConstants.applicationJson;
    }
    handler.next(options);
  }
}
