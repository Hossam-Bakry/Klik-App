import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// A five-star row. Read-only when [onRated] is null, otherwise each star sets
/// the rating to its position.
class OrderRatingStars extends StatelessWidget {
  const OrderRatingStars({
    super.key,
    this.rating = 0,
    this.onRated,
    this.size = 20,
  });

  /// Stars filled, 0–5.
  final int rating;

  final ValueChanged<int>? onRated;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          GestureDetector(
            onTap: onRated == null ? null : () => onRated!(star),
            child: Padding(
              padding: context.edgeSymmetric(horizontal: 2),
              child: Icon(
                star <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                size: context.r(size),
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }
}
