import 'package:flutter/material.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/negotiation.dart';
import '../../domain/entities/negotiation_board.dart';

/// The horizontally scrolling status filter above the list: "All" plus one chip
/// per bucket, each badged with its count. The selected chip is solid bronze.
class NegotiationFilterChips extends StatelessWidget {
  const NegotiationFilterChips({
    super.key,
    required this.board,
    required this.selected,
    required this.onSelected,
  });

  final NegotiationBoard board;

  /// `null` is the "All" chip.
  final NegotiationStatus? selected;
  final ValueChanged<NegotiationStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    // "All" first, then the buckets in the order the design lists them.
    const filters = <NegotiationStatus?>[
      null,
      NegotiationStatus.pending,
      NegotiationStatus.approved,
      NegotiationStatus.rejected,
      NegotiationStatus.expired,
    ];

    return SizedBox(
      height: context.r(40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: context.edgeSymmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => context.gapW(8),
        itemBuilder: (context, i) {
          final filter = filters[i];
          return _Chip(
            label: _label(context, filter),
            icon: _icon(filter),
            // "All" carries no badge in the design — the others always do.
            count: filter == null ? null : board.countOf(filter),
            selected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }

  String _label(BuildContext context, NegotiationStatus? filter) =>
      context.tr(switch (filter) {
        null => LocaleKeys.all,
        NegotiationStatus.pending => LocaleKeys.pending,
        // The chip reads "Accepted" while the row's pill reads "Approved".
        NegotiationStatus.approved => LocaleKeys.accepted,
        NegotiationStatus.rejected => LocaleKeys.rejected,
        NegotiationStatus.expired => LocaleKeys.expired,
      });

  SvgGenImage? _icon(NegotiationStatus? filter) => switch (filter) {
    null => null,
    NegotiationStatus.pending => Assets.icons.pendingIcn,
    NegotiationStatus.approved => Assets.icons.approvedIcn,
    NegotiationStatus.rejected => Assets.icons.rejectedIcn,
    NegotiationStatus.expired => Assets.icons.expiredIcn,
  };
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.count,
  });

  final String label;
  final SvgGenImage? icon;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(20));
    final foreground = selected ? AppColors.surface : AppColors.primaryBronze;

    return Material(
      color: selected
          ? AppColors.primaryBronze
          : AppColors.dark.withValues(alpha: 0.05),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: context.edgeSymmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                // Icon(icon, size: context.r(15), color: foreground),
                icon!.svg(
                  width: context.r(15),
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn)
                ),
                context.gapW(6),
              ],
              Text(
                label,
                style: context.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.surface : AppColors.primaryBronze,
                ),
              ),
              if (count != null) ...[
                context.gapW(6),
                _Badge(count: count!, selected: selected),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The small pill holding a chip's count.
class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: context.r(18)),
      padding: context.edgeSymmetric(horizontal: 5, vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? AppColors.surface.withValues(alpha: 0.25)
            : AppColors.textSecondary.withValues(alpha: 0.18),
        // borderRadius: BorderRadius.circular(context.r(10)),
      ),
      child: Text(
        '$count',
        style: context.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.surface : AppColors.textSecondary,
        ),
      ),
    );
  }
}
