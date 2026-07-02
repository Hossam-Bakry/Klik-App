import 'package:equatable/equatable.dart';

/// A product brand shown in the filter sheet's Brand section.
class Brand extends Equatable {
  const Brand({
    required this.id,
    required this.name,
    this.productsCount = 0,
  });

  final int id;
  final String name;

  /// How many products carry this brand (shown as a count next to the name).
  final int productsCount;

  @override
  List<Object?> get props => [id, name, productsCount];
}
