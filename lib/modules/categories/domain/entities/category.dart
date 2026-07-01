import 'package:equatable/equatable.dart';

/// A top-level catalog category shown on the Categories tab.
class Category extends Equatable {
  const Category({required this.id, required this.name, required this.thumbnail});

  final int id;
  final String name;
  final String thumbnail;

  @override
  List<Object?> get props => [id, name, thumbnail];
}
