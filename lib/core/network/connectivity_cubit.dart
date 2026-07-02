import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Whether the device currently has a network connection. Starts [unknown] so
/// the UI doesn't flash the offline view before the first check resolves.
enum NetworkStatus { unknown, online, offline }

/// App-level cubit that tracks connectivity and keeps it live: it does an
/// initial check, then listens to [Connectivity.onConnectivityChanged] so the
/// UI flips to the offline view when the connection drops and back when it
/// returns.
///
/// The reconnect side of that stream is unreliable on some Android/iOS +
/// device combos (the disconnect event fires promptly, but the "back online"
/// event can be delayed or dropped entirely) — see e.g.
/// https://github.com/fluttercommunity/plus_plugins/issues (connectivity_plus
/// reconnect-detection reports). To guarantee the UI recovers on its own with
/// no user interaction, this also polls on a short interval while offline and
/// rechecks whenever the app resumes from the background.
class ConnectivityCubit extends Cubit<NetworkStatus> with WidgetsBindingObserver {
  ConnectivityCubit(this._connectivity) : super(NetworkStatus.unknown) {
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollTimer;

  static const _pollInterval = Duration(seconds: 3);

  bool get isOffline => state == NetworkStatus.offline;

  Future<void> _start() async {
    _emitFrom(await _connectivity.checkConnectivity());
    // Any stream event (either direction) triggers a fresh check rather than
    // trusting the event's own payload — some platforms report a stale/partial
    // result on the event itself.
    _subscription = _connectivity.onConnectivityChanged.listen((_) => recheck());
  }

  /// Re-check on demand (e.g. a manual "try again" tap, app resume, or the
  /// offline poll timer below).
  Future<void> recheck() async => _emitFrom(await _connectivity.checkConnectivity());

  void _emitFrom(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    emit(online ? NetworkStatus.online : NetworkStatus.offline);
    _syncPolling(online: online);
  }

  /// While offline, poll every [_pollInterval] as a safety net in case the
  /// platform never delivers the reconnect event on its own.
  void _syncPolling({required bool online}) {
    if (online) {
      _pollTimer?.cancel();
      _pollTimer = null;
    } else {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) => recheck());
    }
  }

  /// Catches connectivity changes that happened while the app was backgrounded
  /// (e.g. the user fixed their Wi-Fi from Settings/Control Centre).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) recheck();
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}
