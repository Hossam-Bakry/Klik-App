import 'api_result.dart';

/// Decodes the response payload (the unwrapped `data`, or the raw body when
/// `unwrapEnvelope` is false) into [T].
typedef ApiDecoder<T> = T Function(dynamic data);

/// Abstraction over the HTTP client. Data sources depend on this — not on Dio
/// directly — so the transport is swappable and every call returns an
/// [ApiResult] (envelope unwrapping + error mapping handled centrally).
///
/// [unwrapEnvelope] (default true) extracts `data` from the standard
/// `{ message, data }` response before decoding; pass false for endpoints that
/// return a bare body.
abstract interface class ApiInterface {
  Future<ApiResult<T>> get<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  });

  Future<ApiResult<T>> post<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  });

  Future<ApiResult<T>> put<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  });

  Future<ApiResult<T>> patch<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  });

  Future<ApiResult<T>> delete<T>(
    String path, {
    required ApiDecoder<T> decoder,
    Object? body,
    Map<String, dynamic>? query,
    bool unwrapEnvelope = true,
  });
}
