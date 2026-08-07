import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/repositories/orders_repository.dart';

part 'write_review_state.dart';

/// Page-scoped state for the "Write a Review" screen — one product, one submit.
class WriteReviewCubit extends Cubit<WriteReviewState> {
  WriteReviewCubit(this._repository) : super(const WriteReviewState());

  final OrdersRepository _repository;

  Future<bool> submit({
    required int orderId,
    required int productId,
    required int rating,
    required String description,
    List<File> photos = const [],
  }) async {
    emit(state.copyWith(status: WriteReviewStatus.submitting, clearError: true));

    switch (await _repository.submitReview(
      orderId: orderId,
      productId: productId,
      rating: rating,
      description: description,
      photos: photos,
    )) {
      case ApiSuccess():
        emit(state.copyWith(status: WriteReviewStatus.success));
        return true;
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: WriteReviewStatus.failure,
          errorMessage: failure.message,
        ));
        return false;
    }
  }
}
