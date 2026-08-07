import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/cart/presentation/cart_cubit.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../widgets/cart_item_card.dart';

/// Cart destination (tab index 3). Works for guests too — their cart lives on
/// the device until they sign in, when it's merged into the account.
///
/// [CartCubit] is app-wide (it also feeds the nav badge), so unlike the
/// route-scoped blocs elsewhere there's no `..add(Started())` at a
/// `BlocProvider` to kick off the first read — this page owns that.
class CartPage extends StatefulWidget {
  const CartPage({super.key, this.onBack});

  /// Tapped the back chevron. The cart is a tab, not a pushed route, so the
  /// shell decides where "back" goes.
  final VoidCallback? onBack;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    // The shell keeps this page alive in an IndexedStack, so this runs once.
    // Cheap for a guest — it just reads the device store back.
    context.read<CartCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        // leading: onBack == null
        //     ? null
        //     : IconButton(
        //         icon: const Icon(Icons.arrow_back_ios_new_rounded),
        //         color: AppColors.textPrimary,
        //         onPressed: onBack,
        //       ),
        title: Text(
          context.tr(LocaleKeys.cart),
          style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<CartCubit, CartState>(
        // Surface a failed mutation without disturbing the list.
        listenWhen: (p, c) =>
            c.errorMessage != null && p.errorMessage != c.errorMessage,
        listener: (context, state) =>
            AppToast.error(context, state.errorMessage!),
        builder: (context, state) {
          if (state.isLoading) return const _SkeletonList();

          if (state.status == CartStatus.failure && state.cart.isEmpty) {
            return ErrorView(
              message:
                  state.errorMessage ?? context.tr(LocaleKeys.somethingWentWrong),
              onRetry: () => context.read<CartCubit>().load(),
            );
          }

          if (state.cart.isEmpty) {
            return EmptyView(
              image: Assets.images.emptyCartImg.image(width: context.w(220)),
              message: context.tr(LocaleKeys.cartEmpty),
            );
          }

          return _list(context, state);
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        buildWhen: (p, c) => p.cart != c.cart,
        // The summary bar only exists once there's something to check out.
        builder: (context, state) => state.cart.isEmpty
            ? const SizedBox.shrink()
            : _SummaryBar(
                total: state.cart.total,
                onCheckout: () =>
                    AppToast.info(context, context.tr(LocaleKeys.comingSoon)),
              ),
      ),
    );
  }

  Widget _list(BuildContext context, CartState state) {
    final cubit = context.read<CartCubit>();
    final items = state.cart.items;

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) {
          final item = items[i];
          // Only the row being changed locks — its own stepper dims until the
          // new quantity comes back, while the other rows stay tappable.
          final busy = state.isPending(item.productId);

          return CartItemCard(
            item: item,
            onIncrement: busy ? null : () => cubit.increment(item),
            onDecrement: busy ? null : () => cubit.decrement(item),
            onRemove: busy ? null : () => cubit.remove(item),
          );
        },
      ),
    );
  }
}

/// Sticky footer: the cart total on the left, "Check Out" on the right.
///
/// The shell's nav bar floats over this page (`extendBody: true`), so the bar
/// lifts clear of it — its 55pt body *and* the 27.5pt the centre circle
/// overhangs, which would otherwise sit on top of "Check Out".
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.total, required this.onCheckout});

  final double total;
  final VoidCallback onCheckout;

  /// Height the shell's [CurvedBottomNav] takes above the safe area.
  static const double _navClearance = 75 + 27.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(20))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: context.r(14),
            offset: Offset(0, -context.r(2)),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        context.r(20),
        context.r(16),
        context.r(20),
        context.r(16 + _navClearance) + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr(LocaleKeys.total),
                  style: context.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                context.gapH(4),
                Text(
                  '${total.toStringAsFixed(2)} '
                  '${context.tr(LocaleKeys.currencyKwd)}',
                  style: context.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryGold,
                  ),
                ),
              ],
            ),
          ),
          context.gapW(16),
          Expanded(
            child: AppButton.filled(
              label: context.tr(LocaleKeys.checkOut),
              color: AppColors.primaryBronze,
              cornerRadius: 10,
              onPressed: onCheckout,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder rows shown under a [Skeletonizer] while the cart loads.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  static const _placeholder = CartItem(
    productId: 0,
    name: 'Samsung washing machine',
    thumbnail: '',
    price: 15,
    originalPrice: 22,
    quantity: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
        itemCount: 3,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) => const CartItemCard(item: _placeholder),
      ),
    );
  }
}
