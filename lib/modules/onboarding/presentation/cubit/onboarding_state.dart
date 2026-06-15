part of 'onboarding_cubit.dart';

/// [unknown] is the bootstrap value before the persisted flag is read.
enum OnboardingStatus { unknown, required, completed }

class OnboardingState extends Equatable {
  const OnboardingState({this.status = OnboardingStatus.unknown});

  final OnboardingStatus status;

  @override
  List<Object?> get props => [status];
}
