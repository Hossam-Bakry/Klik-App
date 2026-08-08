import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../orders/presentation/order_details_args.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications_cubit.dart';
import '../widgets/notification_tile.dart';

/// The notifications list (`GET /api/notifications`), reached from the home
/// bell and Profile → Notification.
///
/// [NotificationsCubit] is app-wide (it also feeds the bell's dot), so this
/// page refreshes it on arrival rather than owning the first read.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationsCubit>();
    // Show whatever's already loaded, then bring it up to date.
    cubit.state.items.isEmpty ? cubit.load() : cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final cubit = context.read<NotificationsCubit>();
        if (cubit.state.status == NotificationsStatus.failure) cubit.refresh();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textPrimary),
          title: Text(
            context.tr(LocaleKeys.notification),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state.isLoading) return const _SkeletonList();

            if (state.status == NotificationsStatus.failure &&
                state.items.isEmpty) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: context.read<NotificationsCubit>().load,
              );
            }

            return _list(context, state);
          },
        ),
      ),
    );
  }

  Widget _list(BuildContext context, NotificationsState state) {
    final cubit = context.read<NotificationsCubit>();

    if (state.items.isEmpty) {
      // Pullable so a stale empty list can be retried.
      return RefreshIndicator(
        onRefresh: cubit.refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: EmptyView(
                icon: Icons.notifications_none_rounded,
                message: context.tr(LocaleKeys.noNotificationsYet),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) => NotificationTile(
          notification: state.items[i],
          onTap: () => _open(context, state.items[i]),
        ),
      ),
    );
  }

  /// Marks the row read, then follows it to whatever it's about. A
  /// notification that names nothing just clears its dot.
  Future<void> _open(BuildContext context, AppNotification notification) async {
    unawaited(context.read<NotificationsCubit>().markRead(notification));

    final orderId = notification.orderId;
    if (orderId != null) {
      context.push(
        AppRoutes.orderDetails,
        extra: OrderDetailsArgs(orderId: orderId),
      );
    } else if (notification.kind.isOrder) {
      // An order event with no id to open — the list is the next best thing.
      context.push(AppRoutes.orders);
    }
  }
}

/// Placeholder rows shown under a [Skeletonizer] while the list loads.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  static const _placeholder = AppNotification(
    id: 0,
    title: 'Your order has been confirmed',
    message: 'Order #RC000000 has been confirmed',
    kind: NotificationKind.orderPlaced,
    timeLabel: '10:30 AM',
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
        itemCount: 6,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) =>
            const NotificationTile(notification: _placeholder),
      ),
    );
  }
}
