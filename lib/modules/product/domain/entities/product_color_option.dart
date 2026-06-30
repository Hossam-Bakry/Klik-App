import 'package:equatable/equatable.dart';

/// A selectable colour swatch on the product page. [hex] is the raw colour
/// string from the API (e.g. `#0E0E0E`); the UI parses it into a `Color`.
class ProductColorOption extends Equatable {
  const ProductColorOption({required this.name, required this.hex});

  final String name;
  final String hex;

  @override
  List<Object?> get props => [name, hex];
}
