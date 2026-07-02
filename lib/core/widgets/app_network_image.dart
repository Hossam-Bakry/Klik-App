import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Network image with consistent rounding, a loading spinner, and a graceful
/// fallback. An empty [url] renders a neutral placeholder box — which also lets
/// it sit cleanly inside a Skeletonizer while the feed is loading.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget child = url.isEmpty
        ? _placeholder()
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => _placeholder(
              child: const Icon(
                Icons.broken_image_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            loadingBuilder: (context, image, progress) {
              if (progress == null) return image;
              return _placeholder(
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          );

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _placeholder({Widget? child}) => Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    color: AppColors.primary.withValues(alpha: 0.06),
    child: child,
  );
}
