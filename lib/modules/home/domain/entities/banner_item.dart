import 'package:equatable/equatable.dart';

/// A promotional banner shown in the home hero carousel.
class BannerItem extends Equatable {
  const BannerItem({required this.id, required this.title, required this.thumbnail});

  final int id;
  final String? title;
  final String thumbnail;

  @override
  List<Object?> get props => [id, title, thumbnail];
}
