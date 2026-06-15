part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load of the product list.
class CatalogStarted extends CatalogEvent {
  const CatalogStarted();
}

/// Pull-to-refresh — re-fetches without showing the full-screen loader.
class CatalogRefreshed extends CatalogEvent {
  const CatalogRefreshed();
}
