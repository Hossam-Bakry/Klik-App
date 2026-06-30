import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._repository) : super(const ProductState()) {
    on<ProductDetailsRequested>(_onRequested);
    on<ProductFavoriteToggled>(_onFavoriteToggled);
  }

  final ProductRepository _repository;

  Future<void> _onRequested(
    ProductDetailsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await _repository.getProductDetails(event.productId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ProductStatus.success, product: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: ProductStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  /// Optimistic favourite flip. TODO: persist via the favorite-toggle endpoint
  /// once the favorites repository lands; revert on failure.
  void _onFavoriteToggled(
    ProductFavoriteToggled event,
    Emitter<ProductState> emit,
  ) {
    final product = state.product;
    if (product == null) return;
    emit(state.copyWith(product: product.copyWith(isFavorite: !product.isFavorite)));
  }
}
