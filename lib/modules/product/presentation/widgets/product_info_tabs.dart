import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product_review.dart';

/// "About Product" / "Reviews" switcher with an underline indicator under the
/// active tab, followed by the matching content.
class ProductInfoTabs extends StatefulWidget {
  const ProductInfoTabs({super.key, required this.description, required this.reviews});

  final String description;
  final List<ProductReview> reviews;

  @override
  State<ProductInfoTabs> createState() => _ProductInfoTabsState();
}

class _ProductInfoTabsState extends State<ProductInfoTabs> {
  static const _animDuration = Duration(milliseconds: 250);

  int _tab = 0;

  /// Width of a tab label as laid out, so the sliding underline can match the
  /// active word exactly.
  double _labelWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.size.width;
  }

  @override
  Widget build(BuildContext context) {
    final about = context.tr(LocaleKeys.aboutProduct);
    final reviews = context.tr(LocaleKeys.reviews);
    final labelStyle = (context.bodyMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
    );
    final gap = context.r(24);
    final aboutWidth = _labelWidth(context, about, labelStyle);
    final reviewsWidth = _labelWidth(context, reviews, labelStyle);

    // The underline glides to the active word and resizes to its width.
    final indicatorStart = _tab == 0 ? 0.0 : aboutWidth + gap;
    final indicatorWidth = _tab == 0 ? aboutWidth : reviewsWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full-width grey baseline spanning the screen, with a sliding bronze
        // underline on top that's as wide as the active word.
        Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(height: 1, color: AppColors.border),
            ),
            AnimatedPositionedDirectional(
              duration: _animDuration,
              curve: Curves.easeOutCubic,
              start: indicatorStart,
              bottom: 0,
              width: indicatorWidth,
              height: 2,
              child: const ColoredBox(color: AppColors.primary),
            ),
            Row(
              children: [
                _TabLabel(
                  label: about,
                  selected: _tab == 0,
                  duration: _animDuration,
                  onTap: () => setState(() => _tab = 0),
                ),
                SizedBox(width: gap),
                _TabLabel(
                  label: reviews,
                  selected: _tab == 1,
                  duration: _animDuration,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ],
        ),
        context.gapH(14),
        AnimatedSwitcher(
          duration: _animDuration,
          child: _tab == 0
              ? Align(
                  key: const ValueKey('about'),
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    widget.description,
                    style: context.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                )
              : _ReviewsList(key: const ValueKey('reviews'), reviews: widget.reviews),
        ),
      ],
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.label,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        // Vertical padding only, so the label width equals the text width and
        // the sliding underline (measured the same way) lines up exactly.
        padding: context.edgeSymmetric(vertical: 10),
        child: AnimatedDefaultTextStyle(
          duration: duration,
          style: (context.bodyMedium ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({super.key, required this.reviews});

  final List<ProductReview> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Padding(
        padding: context.edgeSymmetric(vertical: 12),
        child: Text(
          context.tr(LocaleKeys.noReviewsYet),
          style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        for (final r in reviews) ...[
          _ReviewTile(review: r),
          context.gapH(14),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final ProductReview review;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: AppNetworkImage(url: review.avatar, width: context.r(40), height: context.r(40)),
        ),
        context.gapW(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      review.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: context.r(16), color: AppColors.secondary),
                      context.gapW(2),
                      Text(review.rating.toStringAsFixed(1), style: context.labelSmall),
                    ],
                  ),
                ],
              ),
              if (review.date.isNotEmpty)
                Text(
                  review.date,
                  style: context.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
              context.gapH(4),
              Text(
                review.comment,
                style: context.bodySmall?.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
