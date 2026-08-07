import '../error/failure.dart';

/// Outcome of an API call. Instead of throwing, the data/domain layers return
/// an [ApiResult]; callers exhaustively `switch` over the sealed subtypes:
///
/// ```dart
/// switch (await repo.getProducts()) {
///   case ApiSuccess(:final data): // use data
///   case ApiFailure(:final failure): // show failure.message
/// }
/// ```
sealed class ApiResult<T> {
  const ApiResult();
}

/// A 2xx response, decoded into [data]. [message] carries the envelope's
/// `message` field when present.
final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {this.message});

  final T data;
  final String? message;
}

/// A failed call (network, server, parsing, validation, …), carrying a mapped
/// [Failure] with a user-presentable [Failure.message].
final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.failure);

  final Failure failure;
}

extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  T? get dataOrNull => switch (this) {
        ApiSuccess<T>(:final data) => data,
        ApiFailure<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        ApiSuccess<T>() => null,
        ApiFailure<T>(:final failure) => failure,
      };

  /// Transforms the success payload, preserving failures — handy in
  /// repositories for mapping a DTO to a domain entity.
  ApiResult<R> mapData<R>(R Function(T data) transform) => switch (this) {
        ApiSuccess<T>(:final data, :final message) =>
          ApiSuccess<R>(transform(data), message: message),
        ApiFailure<T>(:final failure) => ApiFailure<R>(failure),
      };

  /// Fold both cases into a single value.
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        ApiSuccess<T>(:final data) => onSuccess(data),
        ApiFailure<T>(:final failure) => onFailure(failure),
      };
}

/// Placeholder payload for endpoints with no meaningful response body
/// (e.g. send-otp, reset-password): `ApiResult<Unit>`.
class Unit {
  const Unit();
}

const Unit unit = Unit();
