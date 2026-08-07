import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_summary.dart';
import '../bloc/orders_bloc.dart';
import '../order_details_args.dart';
import '../widgets/order_card.dart';
import '../widgets/order_date_dropdown.dart';
import '../widgets/order_filter_chips.dart';
import '../widgets/review_product_picker_sheet.dart';
import '../write_review_args.dart';

/// The customer's orders (`GET /api/orders`), reached from Profile → Orders.
///
/// The endpoint only filters by status server-side, so the screen loads the
/// orders once and narrows them locally — chips, search and the date window all
/// work on what's already here.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _search = TextEditingController();

  /// The order whose lines are being read for the rating flow — guards against
  /// a second star tap stacking another picker on top.
  int? _ratingOrderId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<OrdersBloc>();
        if (bloc.state.status == OrdersStatus.failure) {
          bloc.add(const OrdersRefreshed());
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
            context.tr(LocaleKeys.orders),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state.status == OrdersStatus.failure && state.orders.isEmpty) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: () =>
                    context.read<OrdersBloc>().add(const OrdersStarted()),
              );
            }

            return Column(
              children: [
                _searchRow(context, state),
                context.gapH(12),
                if (!state.isLoading)
                  OrderFilterChips(
                    selected: state.filter,
                    onSelected: (filter) => context.read<OrdersBloc>().add(
                      OrdersFilterChanged(filter),
                    ),
                  ),
                context.gapH(12),
                Expanded(
                  child: state.isLoading
                      ? const _SkeletonList()
                      : _list(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The search field and the date window, side by side as the design has them.
  Widget _searchRow(BuildContext context, OrdersState state) {
    return Padding(
      padding: context.edge(left: 16, right: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: context.r(40),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: AppTextField.search(
                controller: _search,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                hint: context.tr(LocaleKeys.findItems),
                onChanged: (value) =>
                    context.read<OrdersBloc>().add(OrdersSearchChanged(value)),
              ),
            ),
          ),
          context.gapW(12),
          SizedBox(
            width: context.r(130),
            child: OrderDateDropdown(
              selected: state.dateRange,
              onSelected: (range) =>
                  context.read<OrdersBloc>().add(OrdersDateRangeChanged(range)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, OrdersState state) {
    final rows = state.visible;

    Future<void> refresh() async =>
        context.read<OrdersBloc>().add(const OrdersRefreshed());

    if (rows.isEmpty) {
      // Keep the empty state pullable so a stale list can be retried, and say
      // which kind of empty this is: nothing ordered yet, or nothing matching.
      return RefreshIndicator(
        onRefresh: refresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: EmptyView(
                image: Assets.images.emptyOrderImg.image(width: context.w(200)),
                message: context.tr(
                  state.isFiltered && state.orders.isNotEmpty
                      ? LocaleKeys.noOrdersMatch
                      : LocaleKeys.ordersEmpty,
                ),
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
        itemBuilder: (context, i) => OrderCard(
          order: rows[i],
          onTap: () => _openDetails(context, rows[i]),
          onRate: (stars) => _rate(context, rows[i], stars),
        ),
      ),
    );
  }

  /// Opens the order, then refreshes the list on the way back: a cancellation
  /// (or a review) there changes what this screen should show.
  Future<void> _openDetails(BuildContext context, OrderSummary order) async {
    final bloc = context.read<OrdersBloc>();
    await context.push(
      AppRoutes.orderDetails,
      extra: OrderDetailsArgs(orderId: order.id),
    );
    bloc.add(const OrdersRefreshed());
  }

  /// Tapped a star on a card: go straight to rating — ask which product (when
  /// the order holds more than one) and open the review screen on that star.
  /// The order's lines aren't on the list payload, so they're read first.
  Future<void> _rate(
    BuildContext context,
    OrderSummary order,
    int stars,
  ) async {
    // A second tap while the lines are loading would stack another picker.
    if (_ratingOrderId != null) return;
    setState(() => _ratingOrderId = order.id);

    final bloc = context.read<OrdersBloc>();
    final products = await bloc.loadProducts(order.id);
    if (!context.mounted) return;
    setState(() => _ratingOrderId = null);

    if (products == null || products.isEmpty) {
      AppToast.error(context, context.tr(LocaleKeys.somethingWentWrong));
      return;
    }

    final product = products.length == 1
        ? products.first
        : await showReviewProductPicker(context, products: products);
    if (product == null || !context.mounted) return;

    final posted = await context.push<bool>(
      AppRoutes.writeReview,
      extra: WriteReviewArgs(
        orderId: order.id,
        product: product,
        initialRating: stars,
      ),
    );
    if (posted == true) bloc.add(const OrdersRefreshed());
  }
}

/// Placeholder rows shown under a [Skeletonizer] while the orders load.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  static const _placeholder = OrderSummary(
    id: 0,
    code: '#RC000000',
    status: OrderStatus.pending,
    quantity: 2,
    amount: 30,
    placedLabel: '07 Aug, 2026 11:43 AM',
    paymentMethod: 'Online Payment',
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: context.edge(left: 16, right: 16, bottom: 24),
        itemCount: 5,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) => const OrderCard(order: _placeholder),
      ),
    );
  }
}
