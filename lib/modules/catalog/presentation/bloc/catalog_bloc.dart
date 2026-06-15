import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

part 'catalog_event.dart';
part 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc(this._repository) : super(const CatalogState()) {
    on<CatalogStarted>(_onStarted);
    on<CatalogRefreshed>(_onRefreshed);
  }

  final CatalogRepository _repository;

  Future<void> _onStarted(
    CatalogStarted event,
    Emitter<CatalogState> emit,
  ) async {
    emit(state.copyWith(status: CatalogStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    CatalogRefreshed event,
    Emitter<CatalogState> emit,
  ) async {
    // Keep showing current list while refreshing in the background.
    await _load(emit);
  }

  Future<void> _load(Emitter<CatalogState> emit) async {
    final result = await _repository.getProducts();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: CatalogStatus.success, products: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: CatalogStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }
}
