part of 'security_cubit.dart';

enum SecurityStatus { initial, deleting, deleted, failure }

class SecurityState extends Equatable {
  const SecurityState({
    this.status = SecurityStatus.initial,
    this.errorMessage,
  });

  final SecurityStatus status;
  final String? errorMessage;

  bool get isDeleting => status == SecurityStatus.deleting;

  SecurityState copyWith({
    SecurityStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SecurityState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
