import 'package:equatable/equatable.dart';

import '../../../home/domain/entities/home_product.dart';

/// One page of `GET /api/products` results plus whether more pages follow —
/// the unit the bloc appends while paginating.
class ProductsPage extends Equatable {
  const ProductsPage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final List<HomeProduct> items;

  /// The page number these [items] correspond to (1-based).
  final int page;

  /// Whether another page can be requested after this one.
  final bool hasMore;

  @override
  List<Object?> get props => [items, page, hasMore];
}
