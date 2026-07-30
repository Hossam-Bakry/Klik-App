import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Swipeable product gallery with a discount badge, favourite + share actions
/// overlaid on top, and a "current / total" page counter in the corner.
class ProductImageCarousel extends StatefulWidget {
  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.discountPercentage,
    required this.isFavorite,
    this.onToggleFavorite,
    this.onShare,
  });

  final List<String> images;
  final double discountPercentage;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isEmpty ? [''] : widget.images;
    final radius = BorderRadius.circular(context.r(16));

    return AspectRatio(
      aspectRatio: 1.3,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => AppNetworkImage(
                url: images[i],
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (widget.discountPercentage > 0)
              Positioned(
                top: context.r(12),
                left: context.r(12),
                child: _DiscountBadge(percentage: widget.discountPercentage),
              ),
            Positioned(
              top: context.r(12),
              right: context.r(12),
              child: Row(
                spacing: context.r(5),
                children: [
                  _CircleAction(
                    icon: widget.isFavorite
                        ? Assets.icons.selectedWishlistIcn.svg(
                            width: context.r(20),
                            height: context.r(20),
                            colorFilter: const ColorFilter.mode(
                              AppColors.error,
                              BlendMode.srcIn,
                            ),
                          )
                        : Assets.icons.unSelectedFavoriteIcn.svg(
                            width: context.r(20),
                            height: context.r(20),
                          ),
                    onTap: widget.onToggleFavorite,
                  ),
                  context.gapH(10),
                  _CircleAction(
                    icon: Icon(
                      Icons.share_outlined,
                      size: context.r(18),
                      color: AppColors.primary,
                    ),
                    onTap: widget.onShare,
                  ),
                ],
              ),
            ),
            if (images.length > 1)
              Positioned(
                bottom: context.r(12),
                right: context.r(12),
                child: _PageCounter(current: _page + 1, total: images.length),
              ),
          ],
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBronze,
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Text(
        '${percentage.toStringAsFixed(0)}%',
        style: TextStyle(
          color: AppColors.surface,
          fontWeight: FontWeight.w700,
          fontSize: context.sp(13),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, this.onTap});

  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.r(36),
        height: context.r(36),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: icon,
      ),
    );
  }
}

class _PageCounter extends StatelessWidget {
  const _PageCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.edgeSymmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.dark.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        '$current/$total',
        style: TextStyle(color: AppColors.surface, fontSize: context.sp(12)),
      ),
    );
  }
}
