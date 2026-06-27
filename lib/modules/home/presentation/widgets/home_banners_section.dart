import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/banner_item.dart';

/// Hero banner carousel at the top of the home feed, with page dots.
class HomeBannersSection extends StatefulWidget {
  const HomeBannersSection({super.key, required this.banners});

  final List<BannerItem> banners;

  @override
  State<HomeBannersSection> createState() => _HomeBannersSectionState();
}

class _HomeBannersSectionState extends State<HomeBannersSection> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: context.r(150),
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: context.edgeHorizontal(16),
              child: AppNetworkImage(
                url: widget.banners[i].thumbnail,
                width: double.infinity,
                borderRadius: BorderRadius.circular(context.r(16)),
              ),
            ),
          ),
        ),
        context.gapH(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: context.edgeSymmetric(horizontal: 3),
                width: context.r(i == _page ? 18 : 6),
                height: context.r(6),
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(context.r(3)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
