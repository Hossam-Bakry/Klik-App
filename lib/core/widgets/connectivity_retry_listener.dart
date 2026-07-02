import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/connectivity_cubit.dart';

/// Wraps [child] with a listener that fires [onRestored] exactly once whenever
/// connectivity flips from offline back to online — lets a page silently
/// retry a failed load with no interaction from the user (the global
/// [ConnectivityCubit] already keeps tracking status app-wide; this just
/// reacts to it locally).
class ConnectivityRetryListener extends StatelessWidget {
  const ConnectivityRetryListener({
    super.key,
    required this.onRestored,
    required this.child,
  });

  final VoidCallback onRestored;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, NetworkStatus>(
      listenWhen: (previous, current) =>
          previous == NetworkStatus.offline && current == NetworkStatus.online,
      listener: (context, state) => onRestored(),
      child: child,
    );
  }
}
