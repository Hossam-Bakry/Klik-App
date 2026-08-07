/// Supplies the current access token (or null when signed out) to the network
/// layer. Defined in core so [AuthInterceptor] stays decoupled from the auth
/// module — the auth module registers the concrete implementation in DI.
typedef TokenProvider = Future<String?> Function();
