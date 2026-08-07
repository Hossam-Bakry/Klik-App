import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../modules/home/domain/entities/home_product.dart';
import '../cart/domain/cart_item.dart';
import '../cart/presentation/cart_cubit.dart';
import '../extensions/context_extensions.dart';
import '../localization/locale_keys.dart';
import '../theme/app_colors.dart';
import 'app_toast.dart';

/// Add-to-cart affordances for product cards, wired straight to the shared
/// [CartCubit] the way [ProductFavoriteButton] is wired to favorites — so a tap
/// on any card lands on the nav badge and the cart screen at once, and the same
/// product shows the same quantity wherever it appears.
///
/// Open to guests, like the product screen's Add-to-Cart: a guest's cart lives
/// on the device until they sign in.
///
/// Cards have no size/colour picker, so a line added here carries no variant —
/// [CartCubit.addOne] tops up whatever line the product is already in.

/// The round "+" on a grid card. Adds one unit and toasts the outcome.
///
/// Once the product is in the cart the glyph turns into the cart icon, so a
/// card tells you at a glance what's already been added; tapping again adds
/// another unit.
class ProductAddToCartButton extends StatelessWidget {
  const ProductAddToCartButton({super.key, required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final inCart = context.select<CartCubit, bool>(
      (cubit) => cubit.quantityOf(product.id) > 0,
    );
    final pending = context.select<CartCubit, bool>(
      (cubit) => cubit.state.isPending(product.id),
    );
    // Nothing to add for a sold-out product, or for the dummy products the
    // skeleton renders while a feed loads.
    final enabled = !pending && !product.isOutOfStock && product.id != 0;

    return _RoundButton(
      icon: Icons.add,

      glyph: inCart ? Assets.icons.cartIcn : null,
      filled: inCart ? false : true,
      size: 28,
      iconSize: 18,
      onTap: enabled ? () => _add(context) : null,
    );
  }

  Future<void> _add(BuildContext context) async {
    final added = await context.read<CartCubit>().addOne(product.toCartItem());
    if (!context.mounted || !added) return;
    AppToast.success(context, context.tr(LocaleKeys.addedToCart));
  }
}

/// The "− n +" stepper on a wide product row. Shows how many units of the
/// product are in the cart (0 when it isn't), and steps that up and down;
/// stepping the last unit down drops the line.
class ProductCartStepper extends StatelessWidget {
  const ProductCartStepper({super.key, required this.product});

  final HomeProduct product;

  @override
  Widget build(BuildContext context) {
    final quantity = context.select<CartCubit, int>(
      (cubit) => cubit.quantityOf(product.id),
    );
    final pending = context.select<CartCubit, bool>(
      (cubit) => cubit.state.isPending(product.id),
    );
    final live = !pending && product.id != 0;
    final cubit = context.read<CartCubit>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(
          icon: Icons.remove,
          filled: false,
          // Nothing to take away when the product isn't in the cart yet.
          onTap: live && quantity > 0
              ? () => cubit.removeOne(product.id)
              : null,
        ),
        Padding(
          padding: context.edgeSymmetric(horizontal: 10),
          child: Text(
            '$quantity',
            style: TextStyle(
              fontSize: context.sp(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _RoundButton(
          icon: Icons.add,
          filled: true,
          onTap: live && !product.isOutOfStock
              ? () => cubit.addOne(product.toCartItem())
              : null,
        ),
      ],
    );
  }
}

/// Shared circle button for both controls: bronze-filled for "+", outlined for
/// "−", and faded while it's disabled (sold out, or a change in flight).
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.filled,
    this.glyph,
    this.onTap,
    this.size = 18,
    this.iconSize = 12,
  });

  final IconData icon;

  /// Drawn instead of [icon] when set — the cart glyph an added product shows.
  final SvgGenImage? glyph;

  final bool filled;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final tint = filled ? AppColors.primary : AppColors.primaryBronze;
    final foreground = filled ? Colors.white : tint;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: context.r(size),
          height: context.r(size),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? tint : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: context.r(8),
              offset: Offset(0, context.r(2)),
            )],
            // border: filled
            //     ? null
            //     : Border.all(color: tint.withValues(alpha: 0.4)),
          ),
          child: glyph == null
              ? Icon(icon, size: context.r(iconSize), color: foreground)
              : glyph!.svg(
                  width: context.r(iconSize),
                  height: context.r(iconSize),
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
        ),
      ),
    );
  }
}

extension on HomeProduct {
  /// The cart line for this product as a card knows it: the card has all the
  /// display data a guest cart needs, and no variant to pin down.
  CartItem toCartItem() => CartItem(
    productId: id,
    name: name,
    thumbnail: thumbnail,
    price: effectivePrice,
    originalPrice: price,
  );
}
