import 'package:dio/dio.dart';

import '../error/failure.dart';
import 'api_interface.dart';
import 'api_result.dart';

/// [ApiInterface] backed by Dio. Centralizes two things every call needs:
///   1. unwrapping the `{ message, data }` envelope before decoding, and
///   2. mapping Dio errors (and decode errors) into a [Failure].
///
/// Data sources stay thin: they just pass a path + a [ResponseDecoder].
class DioApiClient implements ApiInterface {
  DioApiClient(this._dio);

  final Dio _dio;

  @override
  Future<ApiResult<T>> get<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  }) =>
      _send(() => _dio.get(path, queryParameters: query), decoder,
          unwrapEnvelope);

  @override
  Future<ApiResult<T>> post<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  }) =>
      _send(() => _dio.post(path, data: body, queryParameters: query), decoder,
          unwrapEnvelope);

  @override
  Future<ApiResult<T>> put<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  }) =>
      _send(() => _dio.put(path, data: body, queryParameters: query), decoder,
          unwrapEnvelope);

  @override
  Future<ApiResult<T>> patch<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  }) =>
      _send(() => _dio.patch(path, data: body, queryParameters: query), decoder,
          unwrapEnvelope);

  @override
  Future<ApiResult<T>> delete<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  }) =>
      _send(() => _dio.delete(path, data: body, queryParameters: query),
          decoder, unwrapEnvelope);

  Future<ApiResult<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    ApiDecoder<T> decoder,
    bool unwrapEnvelope,
  ) async {
    try {
      final response = await request();
      final body = response.data;

      final bool enveloped = unwrapEnvelope && body is Map<String, dynamic>;
      final dynamic payload = enveloped ? body['data'] : body;
      final String? message = enveloped ? body['message'] as String? : null;

      try {
        return ApiSuccess<T>(decoder(payload), message: message);
      } catch (_) {
        return const ApiFailure(ParsingFailure());
      }
    } on DioException catch (e) {
      return ApiFailure<T>(_mapError(e));
    } catch (_) {
      return const ApiFailure(UnknownFailure());
    }
  }

  Failure _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ServerFailure(_serverMessage(e));
    }
  }

  /// Prefer the server's `message` (the API's standard error shape) for
  /// user-facing text; otherwise fall back to Dio's message.
  String _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (e.response?.statusCode == 401) return 'Invalid credentials.';
    return e.message ?? 'Something went wrong on the server.';
  }
}
