import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cart/presentation/cart_cubit.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../address/domain/entities/address.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/widgets/choose_address_sheet.dart';
import '../../domain/entities/payment_method.dart';
import '../cubit/checkout_cubit.dart';
import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_items_card.dart';
import '../widgets/checkout_stepper.dart';
import '../widgets/checkout_summary_card.dart';
import '../widgets/coupon_card.dart';
import '../widgets/payment_details_form.dart';
import '../widgets/payment_method_tile.dart';

/// Checkout: Address → Payment → Review, then the order goes in.
///
/// The cart stays live throughout (the review step edits quantities through the
/// shared [CartCubit]), and the delivery address comes from the shared
/// [AddressBloc] the rest of the app uses.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _coupon = TextEditingController();

  /// The card form replaces the payment step's body when the customer taps
  /// "change" — the design keeps the stepper above it either way.
  bool _editingCard = false;

  @override
  void initState() {
    super.initState();
    // The shell loads the saved addresses on sign-in, but checkout can't
    // proceed without one — ask for them if they aren't here yet.
    final addresses = context.read<AddressBloc>();
    if (!addresses.state.hasAddresses) {
      addresses.add(const AddressStarted());
    }
  }

  @override
  void dispose() {
    _coupon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listenWhen: (p, c) =>
          c.errorMessage != null && p.errorMessage != c.errorMessage,
      listener: (context, state) => AppToast.error(context, state.errorMessage!),
      builder: (context, state) {
        return PopScope(
          // Back walks the steps before it leaves checkout.
          canPop: state.step == CheckoutStep.address && !_editingCard,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _back(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              centerTitle: true,
              leading: BackButton(
                color: AppColors.textPrimary,
                onPressed: () => _back(context),
              ),
              title: Text(
                context.tr(LocaleKeys.checkOut),
                style: context.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _body(context, state),
          ),
        );
      },
    );
  }

  void _back(BuildContext context) {
    if (_editingCard) {
      setState(() => _editingCard = false);
      return;
    }
    if (!context.read<CheckoutCubit>().back()) context.pop();
  }

  Widget _body(BuildContext context, CheckoutState state) {
    final cart = context.watch<CartCubit>().state;

    // Everything was ordered (or removed) out from under the screen.
    if (cart.cart.isEmpty) {
      return EmptyView(
        icon: Icons.shopping_cart_outlined,
        message: context.tr(LocaleKeys.cartEmpty),
      );
    }

    final address = context.select<AddressBloc, Address?>(
      (bloc) => bloc.state.selected ?? bloc.state.addresses.firstOrNull,
    );
    final totals = state.totalsFor(cart.cart.total);

    return Column(
      children: [
        CheckoutStepper(
          current: state.step,
          onStepTapped: (step) {
            setState(() => _editingCard = false);
            context.read<CheckoutCubit>().goTo(step);
          },
        ),
        context.gapH(8),
        Expanded(
          child: ListView(
            padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
            children: [
              ...switch (state.step) {
                CheckoutStep.address => _addressStep(context, address, state),
                CheckoutStep.payment => _paymentStep(context, state),
                CheckoutStep.review => _reviewStep(context, address, state),
              },
              context.gapH(16),
              // The card form has its own Apply button; the steps share the
              // summary + primary action.
              if (!_editingCard) ...[
                CheckoutSummaryCard(
                  summary: totals,
                  itemCount: cart.cart.itemCount,
                ),
                context.gapH(16),
                if (state.step == CheckoutStep.review) ...[
                  _payNote(context, state),
                  context.gapH(12),
                ],
                _primaryAction(context, state, address, totals.total),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---- Steps -------------------------------------------------------------

  List<Widget> _addressStep(
    BuildContext context,
    Address? address,
    CheckoutState state,
  ) {
    return [
      _SectionHeader(
        title: context.tr(LocaleKeys.deliveryAddress),
        actionLabel: context.tr(LocaleKeys.change),
        onAction: () => showChooseAddressSheet(context),
      ),
      context.gapH(10),
      if (address == null)
        _AddAddressPrompt(onTap: () => context.push(AppRoutes.addressAdd))
      else
        CheckoutAddressCard(address: address),
    ];
  }

  List<Widget> _paymentStep(BuildContext context, CheckoutState state) {
    if (_editingCard) {
      return [
        PaymentDetailsForm(
          onApply: (masked) {
            context.read<CheckoutCubit>().setCard(masked);
            setState(() => _editingCard = false);
          },
        ),
      ];
    }

    final cubit = context.read<CheckoutCubit>();

    return [
      Text(
        context.tr(LocaleKeys.paymentMethod),
        style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      context.gapH(10),
      for (final method in PaymentMethod.values) ...[
        PaymentMethodTile(
          method: method,
          selected: state.method == method,
          onTap: () {
            cubit.selectMethod(method);
            if (!method.isAvailable) {
              AppToast.info(context, context.tr(LocaleKeys.paymentComingSoon));
            }
          },
          trailingLabel: method == PaymentMethod.card
              ? (state.cardLabel.isEmpty
                    ? context.tr(LocaleKeys.change)
                    : state.cardLabel)
              : null,
          onTrailingTap: method == PaymentMethod.card
              ? () => setState(() => _editingCard = true)
              : null,
        ),
        context.gapH(10),
      ],
      context.gapH(4),
      CouponCard(
        controller: _coupon,
        applying: state.couponStatus == CouponStatus.applying,
        appliedCode: state.hasCoupon ? state.couponCode : '',
        onApply: () => cubit.applyCoupon(_coupon.text),
      ),
    ];
  }

  List<Widget> _reviewStep(
    BuildContext context,
    Address? address,
    CheckoutState state,
  ) {
    final cartCubit = context.read<CartCubit>();
    final cart = context.watch<CartCubit>().state;

    return [
      if (address != null) ...[
        _SectionHeader(title: context.tr(LocaleKeys.deliveryAddress)),
        context.gapH(10),
        CheckoutAddressCard(address: address, showSelectedMark: false),
        context.gapH(16),
      ],
      CheckoutItemsCard(
        items: cart.cart.items,
        isPending: (item) => cart.isPending(item.productId),
        onIncrement: (item) async {
          await cartCubit.increment(item);
          if (context.mounted) context.read<CheckoutCubit>().refreshTotals();
        },
        onDecrement: (item) async {
          await cartCubit.decrement(item);
          if (context.mounted) context.read<CheckoutCubit>().refreshTotals();
        },
      ),
    ];
  }

  /// The cash-on-delivery note under the review summary.
  Widget _payNote(BuildContext context, CheckoutState state) {
    return Container(
      width: double.infinity,
      padding: context.edgeAll(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBronze.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.r(8)),
      ),
      child: Text(
        context.tr(
          state.method == PaymentMethod.cash
              ? LocaleKeys.payWithCashNote
              : LocaleKeys.paymentPendingNote,
        ),
        style: context.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _primaryAction(
    BuildContext context,
    CheckoutState state,
    Address? address,
    double paidTotal,
  ) {
    final isReview = state.step == CheckoutStep.review;

    return AppButton.filled(
      label: context.tr(isReview ? LocaleKeys.placeOrder : LocaleKeys.payNow),
      cornerRadius: 10,
      isLoading: state.isPlacing,
      onPressed: state.isPlacing
          ? null
          : () => isReview
                ? _placeOrder(context, address, paidTotal)
                : _advance(context, address),
    );
  }

  // ---- Actions -----------------------------------------------------------

  void _advance(BuildContext context, Address? address) {
    // An order can't go anywhere without somewhere to send it.
    if (address?.id == null) {
      AppToast.error(context, context.tr(LocaleKeys.selectAddress));
      return;
    }
    context.read<CheckoutCubit>().next();
  }

  Future<void> _placeOrder(
    BuildContext context,
    Address? address,
    double paidTotal,
  ) async {
    final addressId = address?.id;
    if (addressId == null) {
      AppToast.error(context, context.tr(LocaleKeys.selectAddress));
      return;
    }

    // The total on screen travels with the call: it's what the customer agreed
    // to, and the confirmation shows it when the server names no figure.
    final order = await context.read<CheckoutCubit>().placeOrder(
      addressId: addressId,
      paidTotal: paidTotal,
    );
    if (order == null || !context.mounted) return;

    // Replace checkout in the stack — there's nothing to come back to.
    context.pushReplacement(AppRoutes.orderSuccess, extra: order);
  }
}

/// A step's title with an optional "change ›" on the right.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBronze,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: context.r(18),
                  color: AppColors.primaryBronze,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Shown when the account has no address to deliver to yet.
class _AddAddressPrompt extends StatelessWidget {
  const _AddAddressPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(10)),
      child: Container(
        width: double.infinity,
        padding: context.edgeAll(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(10)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_location_alt_outlined,
              color: AppColors.primaryBronze,
              size: context.r(22),
            ),
            context.gapW(10),
            Text(
              context.tr(LocaleKeys.addNewAddress),
              style: context.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBronze,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
