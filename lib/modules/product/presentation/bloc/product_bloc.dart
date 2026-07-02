import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc(this._repository, this._favorites) : super(const ProductState()) {
    on<ProductDetailsRequested>(_onRequested);
  }

  final ProductRepository _repository;
  final FavoritesCubit _favorites;

  Future<void> _onRequested(
    ProductDetailsRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));
    final result = await _repository.getProductDetails(event.productId);
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: ProductStatus.success, product: data));
        _favorites.seed([
          if (data.isFavorite) data.id,
          ...data.similarProducts.where((p) => p.isFavorite).map((p) => p.id),
        ]);
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: ProductStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
