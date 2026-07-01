import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/sub_category.dart';
import '../../domain/repositories/categories_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this._repository) : super(const CategoriesState()) {
    on<CategoriesStarted>(_onStarted);
    on<CategoriesRefreshed>(_onRefreshed);
    on<CategoryTapped>(_onCategoryTapped);
  }

  final CategoriesRepository _repository;

  Future<void> _onStarted(
    CategoriesStarted event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(state.copyWith(status: CategoriesStatus.loading));
    await _load(emit);
  }

  Future<void> _onRefreshed(
    CategoriesRefreshed event,
    Emitter<CategoriesState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<CategoriesState> emit) async {
    final result = await _repository.fetchCategories();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(status: CategoriesStatus.success, categories: data));
      case ApiFailure(:final failure):
        emit(state.copyWith(
          status: CategoriesStatus.failure,
          errorMessage: failure.message,
        ));
    }
  }

  /// Tapping a tile toggles its inline subcategories panel. A category with
  /// no subcategories navigates straight to its products instead (signalled
  /// via [CategoriesState.navigateToCategory] + a bumped [navigationToken]).
  Future<void> _onCategoryTapped(
    CategoryTapped event,
    Emitter<CategoriesState> emit,
  ) async {
    final category = event.category;

    if (state.expandedCategoryId == category.id) {
      emit(state.copyWith(clearExpandedCategoryId: true));
      return;
    }

    final cached = state.subCategoriesCache[category.id];
    if (cached != null) {
      _applySubCategories(emit, category, cached);
      return;
    }

    emit(state.copyWith(
      expandedCategoryId: category.id,
      subCategoriesStatus: SubCategoriesStatus.loading,
    ));

    final result = await _repository.fetchSubCategories(category.id);
    switch (result) {
      case ApiSuccess(:final data):
        final cache = Map<int, List<SubCategory>>.from(state.subCategoriesCache)
          ..[category.id] = data;
        emit(state.copyWith(subCategoriesCache: cache));
        _applySubCategories(emit, category, data);
      case ApiFailure(:final failure):
        emit(state.copyWith(
          clearExpandedCategoryId: true,
          subCategoriesStatus: SubCategoriesStatus.failure,
          subCategoriesErrorMessage: failure.message,
        ));
    }
  }

  void _applySubCategories(
    Emitter<CategoriesState> emit,
    Category category,
    List<SubCategory> subCategories,
  ) {
    if (subCategories.isEmpty) {
      emit(state.copyWith(
        clearExpandedCategoryId: true,
        subCategoriesStatus: SubCategoriesStatus.idle,
        navigateToCategory: category,
        navigationToken: state.navigationToken + 1,
      ));
    } else {
      emit(state.copyWith(
        expandedCategoryId: category.id,
        subCategoriesStatus: SubCategoriesStatus.success,
      ));
    }
  }
}
