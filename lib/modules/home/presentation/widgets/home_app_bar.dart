import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/widgets/choose_address_sheet.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';

/// Top greeting row: a two-line welcome on the leading side and a notification
/// bell on the trailing side.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            // Managing delivery addresses needs an account; guests are prompted
            // to sign in.
            onTap: () =>
                context.requireAuth(() => showChooseAddressSheet(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Text(
                      context.tr(LocaleKeys.deliverTo),
                      style: context.titleMedium?.copyWith(
                        fontWeight: FontWeight.w400
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 24, color: AppColors.textPrimary.withValues(alpha: 0.7)),
                  ],
                ),
                context.gapH(2),
                BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    final label = state.deliveryLabel ??
                        (state.locating
                            ? context.tr(LocaleKeys.locating)
                            : context.tr(LocaleKeys.selectAddress));
                    return Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        // The dot tracks the app-wide unread tally; a guest has none, and the
        // route is auth-gated anyway.
        _NotificationButton(
          hasNew: context.select<NotificationsCubit, bool>(
            (cubit) => cubit.state.hasUnread,
          ),
          onTap: () => context.requireAuth(
            () => context.push(AppRoutes.notifications),
          ),
        ),
      ],
    );
  }
}

/// Notification bell with a small red dot on the top-right corner that marks
/// unread notifications when [hasNew] is true.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap, this.hasNew = false});

  final VoidCallback onTap;
  final bool hasNew;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: context.r(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Assets.icons.notificationIcn.svg(width: context.w(30)),
          if (hasNew)
            Positioned(
              top: -context.r(-2),
              right: -context.r(-2),
              child: Container(
                width: context.r(10),
                height: context.r(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  // A ring in the surface color so the dot reads clearly.
                  // border: Border.all(color: AppColors.surface, width: context.r(1.5)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
