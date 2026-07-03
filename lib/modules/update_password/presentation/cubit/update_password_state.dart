part of 'update_password_cubit.dart';

enum UpdatePasswordStatus { initial, submitting, success, failure }

class UpdatePasswordState extends Equatable {
  const UpdatePasswordState({
    this.status = UpdatePasswordStatus.initial,
    this.errorMessage,
  });

  final UpdatePasswordStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == UpdatePasswordStatus.submitting;

  UpdatePasswordState copyWith({
    UpdatePasswordStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UpdatePasswordState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
