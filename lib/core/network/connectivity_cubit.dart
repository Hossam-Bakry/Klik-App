import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Whether the device currently has a network connection. Starts [unknown] so
/// the UI doesn't flash the offline view before the first check resolves.
enum NetworkStatus { unknown, online, offline }

/// App-level cubit that tracks connectivity and keeps it live: it does an
/// initial check, then listens to [Connectivity.onConnectivityChanged] so the
/// UI flips to the offline view when the connection drops and back when it
/// returns.
class ConnectivityCubit extends Cubit<NetworkStatus> {
  ConnectivityCubit(this._connectivity) : super(NetworkStatus.unknown) {
    _start();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOffline => state == NetworkStatus.offline;

  Future<void> _start() async {
    _emitFrom(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen(_emitFrom);
  }

  /// Re-check on demand (e.g. a manual "try again" tap).
  Future<void> recheck() async => _emitFrom(await _connectivity.checkConnectivity());

  /// Online when at least one interface is something other than `none`.
  void _emitFrom(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    emit(online ? NetworkStatus.online : NetworkStatus.offline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
