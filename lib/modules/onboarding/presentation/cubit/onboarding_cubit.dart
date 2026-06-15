import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/onboarding_local_data_source.dart';

part 'onboarding_state.dart';

/// App-level Cubit (a Cubit is enough — no complex events). The router guard
/// reads its [status] to decide whether to show onboarding on launch.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._local) : super(const OnboardingState());

  final OnboardingLocalDataSource _local;

  /// Called once at startup to resolve the persisted flag. Must always resolve
  /// (the splash guard waits on it) — a read failure falls back to "required".
  Future<void> check() async {
    bool done;
    try {
      done = await _local.hasCompletedOnboarding();
    } catch (_) {
      done = false;
    }
    emit(OnboardingState(
      status: done ? OnboardingStatus.completed : OnboardingStatus.required,
    ));
  }

  /// Called when the user finishes the onboarding carousel.
  Future<void> complete() async {
    await _local.markCompleted();
    emit(const OnboardingState(status: OnboardingStatus.completed));
  }
}
