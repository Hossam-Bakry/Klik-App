import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/api_result.dart';
import '../domain/favorites_repository.dart';

/// Global set of favorited product ids, shared by every product card in the
/// app (home, categories, product details) so toggling a favorite on one
/// screen is instantly reflected everywhere else showing the same product.
class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit(this._repository) : super(const {});

  final FavoritesRepository _repository;

  bool isFavorite(int productId) => state.contains(productId);

  /// Drops all locally-known favorites. Called on logout so a signed-out (or
  /// different) account never sees the previous session's favorited ids.
  void clear() => emit(const {});

  /// Merges ids the server already reported as favorite into local state.
  /// Called by list/detail blocs after a successful fetch — additive only, so
  /// it never clobbers a toggle the user already made locally.
  void seed(Iterable<int> favoriteIds) => emit({...state, ...favoriteIds});

  Future<void> toggle(int productId) async {
    final wasFavorite = state.contains(productId);
    emit(_toggled(productId, addingFavorite: !wasFavorite));

    final result = await _repository.toggle(productId);
    if (result.isFailure) {
      emit(_toggled(productId, addingFavorite: wasFavorite));
    }
  }

  Set<int> _toggled(int productId, {required bool addingFavorite}) {
    final next = Set<int>.from(state);
    if (addingFavorite) {
      next.add(productId);
    } else {
      next.remove(productId);
    }
    return next;
  }
}
