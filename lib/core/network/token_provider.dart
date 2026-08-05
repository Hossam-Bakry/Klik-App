/// Supplies the current access token (or null when signed out) to the network
/// layer. Defined in core so [AuthInterceptor] stays decoupled from the auth
/// module — the auth module registers the concrete implementation in DI.
typedef TokenProvider = Future<String?> Function();

/// Supplies the current guest cart token (or null before the guest's first
/// add), read synchronously so [GuestTokenInterceptor] can attach it per
/// request. Backed by the guest cart store in DI.
typedef GuestTokenProvider = String? Function();
