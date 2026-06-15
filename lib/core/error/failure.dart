import 'package:equatable/equatable.dart';

/// Base type for all recoverable errors surfaced to the presentation layer.
///
/// The API client maps low-level Dio errors into a [Failure] and wraps it in
/// an `ApiFailure`, so BLoCs never deal with raw network/parse errors.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// The server responded with a non-success status code.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

/// No connectivity / request timed out / DNS failure, etc.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Response could not be parsed into the expected shape.
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Unexpected response from server.']);
}

/// Client-side input validation failed (e.g. empty fields) — produced by use
/// cases before a request is made.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Catch-all for anything we did not explicitly map.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
