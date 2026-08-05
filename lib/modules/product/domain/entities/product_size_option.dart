import 'package:equatable/equatable.dart';

/// A selectable size/variant chip on the product page (e.g. "128GB").
class ProductSizeOption extends Equatable {
  const ProductSizeOption({required this.label, this.id});

  /// Variant id, sent as `size` when placing a bid. Null when the payload
  /// carries no id for the chip.
  final int? id;

  final String label;

  @override
  List<Object?> get props => [id, label];
}
