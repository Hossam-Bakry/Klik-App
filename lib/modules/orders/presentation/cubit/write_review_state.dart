part of 'write_review_cubit.dart';

enum WriteReviewStatus { initial, submitting, success, failure }

class WriteReviewState extends Equatable {
  const WriteReviewState({
    this.status = WriteReviewStatus.initial,
    this.errorMessage,
  });

  final WriteReviewStatus status;
  final String? errorMessage;

  bool get isSubmitting => status == WriteReviewStatus.submitting;

  WriteReviewState copyWith({
    WriteReviewStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WriteReviewState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
