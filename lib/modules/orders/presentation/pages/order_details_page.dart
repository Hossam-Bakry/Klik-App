import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/order_details.dart';
import '../cubit/order_details_cubit.dart';
import '../widgets/cancel_order_dialog.dart';
import '../widgets/order_address_panel.dart';
import '../widgets/order_lines_card.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/order_timeline.dart';
import '../widgets/return_policy_sheet.dart';
import '../widgets/review_product_picker_sheet.dart';
import '../write_review_args.dart';

/// One order in full (`GET /api/order-details`): where it's going, how far it's
/// got, what's in it, and what it came to — plus the actions the design puts at
/// the bottom (Get Help, and Review or Cancel depending on the status).
class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({super.key});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final cubit = context.read<OrderDetailsCubit>();
        if (cubit.state.status == OrderDetailsStatus.failure) cubit.load();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: AppColors.textPrimary),
          title: Text(
            context.tr(LocaleKeys.orderDetails),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocConsumer<OrderDetailsCubit, OrderDetailsState>(
          listenWhen: (p, c) =>
              c.errorMessage != null && p.errorMessage != c.errorMessage,
          listener: (context, state) {
            AppToast.error(context, state.errorMessage!);
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final order = state.order;
            if (order == null) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: context.read<OrderDetailsCubit>().load,
              );
            }

            return _body(context, order);
          },
        ),
        bottomNavigationBar: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          builder: (context, state) {
            final order = state.order;
            if (order == null) return const SizedBox.shrink();
            return _actions(context, order, busy: state.isBusy);
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, OrderDetails order) {
    return RefreshIndicator(
      onRefresh: context.read<OrderDetailsCubit>().load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
        children: [
          OrderAddressPanel(address: order.address),
          context.gapH(16),
          OrderTimeline(order: order),
          context.gapH(16),
          if (order.products.isNotEmpty) ...[
            OrderLinesCard(
              lines: order.products,
              onLineTap: (line) => context.push(
                AppRoutes.productDetails,
                extra: line.productId,
              ),
            ),
            context.gapH(16),
          ],
          OrderSummaryCard(order: order),
        ],
      ),
    );
  }

  /// Footer: "Get Help" always, with Review under it for a delivered order and
  /// Cancel Order while the shop can still stop it.
  Widget _actions(BuildContext context, OrderDetails order, {required bool busy}) {
    final canReview = order.status.isDelivered && order.products.isNotEmpty;
    final canCancel = order.status.isCancellable;

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.r(16),
        context.r(12),
        context.r(16),
        context.r(12) + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: context.r(16),
            offset: Offset(0, -context.r(4)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton.filled(
                  label: context.tr(LocaleKeys.getHelp),
                  cornerRadius: 10,
                  leading: Icon(
                    Icons.headset_mic_outlined,
                    size: context.r(18),
                    color: Colors.white,
                  ),
                  onPressed: busy ? null : () => _help(context),
                ),
              ),
              if (canReview) ...[
                context.gapW(12),
                Expanded(
                  child: AppButton.outline(
                    label: context.tr(LocaleKeys.review),
                    onPressed: busy ? null : () => _review(context, order),
                  ),
                ),
              ],
            ],
          ),
          if (canCancel) ...[
            context.gapH(4),
            AppButton.text(
              label: context.tr(LocaleKeys.cancelOrder),
              foregroundColor: AppColors.error,
              onPressed: busy ? null : () => _cancel(context),
            ),
          ],
        ],
      ),
    );
  }

  /// Opens the review screen for one product. An order with several lines gets
  /// a picker first — the screen (and the endpoint) rate a single product.
  Future<void> _review(BuildContext context, OrderDetails order) async {
    final cubit = context.read<OrderDetailsCubit>();

    final product = order.products.length == 1
        ? order.products.first
        : await showReviewProductPicker(context, products: order.products);
    if (product == null || !context.mounted) return;

    final posted = await context.push<bool>(
      AppRoutes.writeReview,
      extra: WriteReviewArgs(orderId: order.id, product: product),
    );
    // A posted review can change what the order shows (its rating), so re-read.
    if (posted == true) await cubit.load();
  }

  Future<void> _cancel(BuildContext context) async {
    final cubit = context.read<OrderDetailsCubit>();

    final choice = await showCancelOrderDialog(context);
    if (!context.mounted) return;

    switch (choice) {
      case CancelOrderChoice.dismiss:
        return;
      case CancelOrderChoice.returnPolicy:
        // The link under the buttons — show the rules instead of cancelling.
        await _help(context);
        return;
      case CancelOrderChoice.confirm:
        final cancelled = await cubit.cancel();
        if (!context.mounted || !cancelled) return;
        AppToast.success(context, context.tr(LocaleKeys.orderCancelledMessage));
    }
  }

  /// "Get Help": what can be returned, with a link out to the full policy.
  Future<void> _help(BuildContext context) async {
    final wantsMore = await showReturnPolicySheet(context);
    if (!wantsMore || !context.mounted) return;
    // No policy screen or endpoint exists yet — same placeholder Terms and
    // Privacy sit behind on the profile.
    AppToast.info(context, context.tr(LocaleKeys.comingSoon));
  }
}
