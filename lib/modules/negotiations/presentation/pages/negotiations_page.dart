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
import '../../domain/entities/negotiation.dart';
import '../bloc/negotiations_bloc.dart';
import '../widgets/negotiation_card.dart';
import '../widgets/negotiation_filter_chips.dart';

/// "My Negotiations" (`GET /api/bids`), reached from Profile → My Negotiation.
///
/// The API returns every status bucket in one call, so the chips filter the
/// loaded rows locally — switching tabs never re-hits the network.
class NegotiationsPage extends StatelessWidget {
  const NegotiationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<NegotiationsBloc>();
        if (bloc.state.status == NegotiationsStatus.failure) {
          bloc.add(const NegotiationsRefreshed());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textPrimary),
          title: Text(
            context.tr(LocaleKeys.myNegotiations),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<NegotiationsBloc, NegotiationsState>(
          builder: (context, state) {
            if (state.status == NegotiationsStatus.failure) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: () => context.read<NegotiationsBloc>().add(
                  const NegotiationsStarted(),
                ),
              );
            }
            if (state.isLoading) return const _SkeletonList();

            return Column(
              children: [
                context.gapH(4),
                NegotiationFilterChips(
                  board: state.board,
                  selected: state.filter,
                  onSelected: (filter) => context.read<NegotiationsBloc>().add(
                    NegotiationsFilterChanged(filter),
                  ),
                ),
                context.gapH(12),
                Expanded(child: _list(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _list(BuildContext context, NegotiationsState state) {
    final rows = state.visible;

    Future<void> refresh() async =>
        context.read<NegotiationsBloc>().add(const NegotiationsRefreshed());

    if (rows.isEmpty) {
      // Keep the empty state pullable so a stale/filtered list can be retried.
      return RefreshIndicator(
        onRefresh: refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: EmptyView(
                icon: Icons.gavel_rounded,
                message: context.tr(LocaleKeys.noNegotiationsYet),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context.edge(left: 16, right: 16, bottom: 24),
        itemCount: rows.length,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) => NegotiationCard(
          negotiation: rows[i],
          onTap: () => context.push(
            AppRoutes.productDetails,
            extra: rows[i].productId,
          ),
        ),
      ),
    );
  }
}

/// Placeholder rows shown under a [Skeletonizer] while the offers load.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  static final _placeholder = Negotiation(
    bidId: 0,
    productId: 0,
    name: 'Samsung washing machine',
    thumbnail: '',
    status: NegotiationStatus.pending,
    bidAmount: 15,
    listedPrice: 22,
    submittedAt: DateTime(2026, 6, 27),
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: context.edge(left: 16, right: 16, top: 16, bottom: 24),
        itemCount: 6,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) => NegotiationCard(negotiation: _placeholder),
      ),
    );
  }
}
