part of 'support_cubit.dart';

enum SupportStatus { initial, submitting, success, failure }

class SupportState extends Equatable {
  const SupportState({
    this.status = SupportStatus.initial,
    this.errorMessage,
  });

  final SupportStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == SupportStatus.submitting;

  SupportState copyWith({
    SupportStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupportState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
