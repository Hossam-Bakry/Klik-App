import 'package:equatable/equatable.dart';

/// Represents an authenticated session. Today it only carries the access
/// token; extend with user profile / refresh token / expiry as the API grows.
class AuthSession extends Equatable {
  const AuthSession({required this.token});

  final String token;

  @override
  List<Object?> get props => [token];
}
