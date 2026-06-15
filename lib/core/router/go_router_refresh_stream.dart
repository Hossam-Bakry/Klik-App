import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a [Stream] (e.g. a BLoC's state stream) into a [Listenable] so it can
/// be passed to GoRouter's `refreshListenable`. Every stream event triggers a
/// re-evaluation of the router's `redirect` guard.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
