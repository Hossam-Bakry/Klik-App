import 'package:equatable/equatable.dart';

/// A single customer review shown under the "Reviews" tab.
class ProductReview extends Equatable {
  const ProductReview({
    required this.id,
    required this.authorName,
    required this.avatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final int id;
  final String authorName;
  final String avatar;
  final double rating;
  final String comment;

  /// Pre-formatted date as the API returns it (e.g. "2024-06-30").
  final String date;

  @override
  List<Object?> get props => [id, authorName, rating, comment, date];
}
