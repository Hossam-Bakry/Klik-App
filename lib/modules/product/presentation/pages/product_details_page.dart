import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/cart/domain/cart_item.dart';
import '../../../../core/cart/presentation/cart_cubit.dart';
import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';
import '../../domain/entities/product_details.dart';
import '../bloc/product_bloc.dart';
import '../widgets/bid_status_banner.dart';
import '../widgets/negotiate_offer_card.dart';
import '../widgets/price_negotiate_sheet.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_color_selector.dart';
import '../widgets/product_image_carousel.dart';
import '../widgets/product_info_tabs.dart';
import '../widgets/product_size_selector.dart';
import '../widgets/similar_products_section.dart';

/// Product detail screen: image gallery, variants, description/reviews tabs, a
/// "Similar products" rail and the Add-to-Cart / Buy-Now footer. Driven by
/// [ProductBloc]; variant selection is local UI state.
class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  /// Chosen variant chips, null until the customer picks one. Nothing is
  /// selected on their behalf: a product that varies by colour/size can't go
  /// into the cart on an unpicked variant, so the pick has to be theirs.
  int? _colorIndex;
  int? _sizeIndex;

  /// The product whose selection we've already aligned, so the one-time sync to
  /// the server-selected bid variant doesn't fight the user's later taps.
  int? _syncedProductId;

  /// Set once an Add-to-Cart / Buy-Now tap has been turned away for a missing
  /// variant, so the inline messages only show up after the customer acts.
  bool _showVariantErrors = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      // Two concerns: align the size/colour pick to the server-selected bid
      // variant when a product first loads, and toast the offer outcome once
      // per submission (success/failure) — the refetch on success then updates
      // the negotiate card in place.
      listenWhen: (p, c) =>
          c.product?.id != p.product?.id ||
          (p.bidStatus != c.bidStatus &&
              (c.bidStatus == BidSubmissionStatus.success ||
                  c.bidStatus == BidSubmissionStatus.failure)),
      listener: (context, state) {
        final product = state.product;
        if (product != null && product.id != _syncedProductId) {
          final (size, color) = _initialSelection(product);
          setState(() {
            _syncedProductId = product.id;
            _sizeIndex = size;
            _colorIndex = color;
            _showVariantErrors = false;
          });
        }
        if (state.bidStatus == BidSubmissionStatus.success) {
          AppToast.success(
            context,
            state.bidMessage ?? context.tr(LocaleKeys.bidSubmitted),
          );
        } else if (state.bidStatus == BidSubmissionStatus.failure) {
          AppToast.error(
            context,
            state.bidMessage ?? context.tr(LocaleKeys.somethingWentWrong),
          );
        }
      },
      child: _buildScaffold(context),
    );
  }

  /// The (size, colour) chip indices that match the server-selected bid variant,
  /// so the page opens on the variant the offer state belongs to. Null on both
  /// axes when there's no bid, and on either axis the bid doesn't pin down —
  /// an unmatched axis stays unpicked rather than falling back to the first
  /// chip, which would put a variant the customer never chose into the cart.
  (int?, int?) _initialSelection(ProductDetails product) {
    final bid = product.bid;
    if (bid == null) return (null, null);
    return (
      _indexOfId(product.sizes, bid.sizeId, (s) => s.id),
      _indexOfId(product.colors, bid.colorId, (c) => c.id),
    );
  }

  int? _indexOfId<T>(List<T> options, int? id, int? Function(T) idOf) {
    if (id == null) return null;
    final i = options.indexWhere((o) => idOf(o) == id);
    return i < 0 ? null : i;
  }

  /// Whether the product varies by that axis and the customer hasn't picked yet.
  bool _colorMissing(ProductDetails product) =>
      product.colors.isNotEmpty && _colorIndex == null;

  bool _sizeMissing(ProductDetails product) =>
      product.sizes.isNotEmpty && _sizeIndex == null;

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        toolbarHeight: context.h(30),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.failure && state.product == null) {
            return ErrorView(
              message:
                  state.errorMessage ??
                  context.tr(LocaleKeys.somethingWentWrong),
              onRetry: () => _reload(context),
            );
          }
          // While loading, the real layout renders against a dummy product
          // wrapped in a Skeletonizer so the page shows shimmering bones
          // instead of a spinner (same approach as the home feed).
          final loading = state.isLoading || state.product == null;
          final product = loading
              ? ProductDetails.placeholder()
              : state.product!;
          return Skeletonizer(
            enabled: loading,
            child: _Content(
              product: product,
              colorIndex: loading ? null : _colorIndex,
              sizeIndex: loading ? null : _sizeIndex,
              // Picking clears that axis' message on its own, since the flags
              // are read off the current selection.
              colorError:
                  !loading && _showVariantErrors && _colorMissing(product),
              sizeError:
                  !loading && _showVariantErrors && _sizeMissing(product),
              onColorSelected: (i) => setState(() => _colorIndex = i),
              onSizeSelected: (i) => setState(() => _sizeIndex = i),
              onOpenNegotiate: () => _openNegotiate(context, product),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final product = state.product;
          // Failed with nothing to show: no footer at all. Still loading: bones,
          // so the CTAs don't pop in under the user's thumb.
          if (product == null) {
            return state.status == ProductStatus.failure
                ? const SizedBox.shrink()
                : const Skeletonizer(enabled: true, child: ProductBottomBar());
          }
          // Out of stock: swap the CTAs for a disabled "Out Of Stock" banner.
          if (product.isOutOfStock) return const _OutOfStockBar();
          return ProductBottomBar(
            onAddToCart: () => _addToCart(context, product),
            // Same gate as Add-to-Cart: buying is buying a variant, and the
            // customer picks it before we ask them to sign in.
            onBuyNow: () {
              if (!_ensureVariantsPicked(context, product)) return;
              context.requireAuth(() => _comingSoon(context));
            },
          );
        },
      ),
    );
  }

  void _reload(BuildContext context) {
    final id = context.read<ProductBloc>().state.product?.id;
    if (id != null) {
      context.read<ProductBloc>().add(ProductDetailsRequested(id));
    }
  }

  /// Opens the "Price Negotiate" sheet, then acts on what the customer chose.
  /// Offers belong to an account, so a guest gets the sign-in prompt first.
  ///
  /// Both outcomes need endpoints the API doesn't expose yet (bids, cart), so
  /// the UI is complete but the actions land on the coming-soon toast: wire the
  /// offer to a `ProductBloc` event (POST the amount, refresh the product's bid)
  /// and checkout to the cart flow once those exist.
  Future<void> _openNegotiate(
    BuildContext context,
    ProductDetails product,
  ) async {
    // An offer is an offer on one variant, so the pick comes before the sheet —
    // otherwise the bid would go up with no size or colour on it.
    if (!_ensureVariantsPicked(context, product)) return;
    if (!context.isAuthenticated) {
      await showAuthRequiredSheet(context);
      return;
    }
    final bloc = context.read<ProductBloc>();
    // Negotiate against the variant the customer has picked, so the suggested
    // offer, floor and status match their size/colour selection.
    final sizeId = _optionId(product.sizes, _sizeIndex, (s) => s.id);
    final colorId = _optionId(product.colors, _colorIndex, (c) => c.id);
    final bid = product.bidForVariant(sizeId: sizeId, colorId: colorId);
    final result = await showPriceNegotiateSheet(
      context,
      bid: bid,
      // Offers are negotiated against the variant's listed price when present,
      // else the product price actually on sale.
      listedPrice: bid?.listedPrice ??
          (product.hasDiscount ? product.discountPrice : product.price),
      currency: context.tr(LocaleKeys.currencyKwd),
      // Show what's on the table: the product and the variant just resolved.
      productName: product.name,
      productImage: product.images.isEmpty ? '' : product.images.first,
      sizeLabel: _optionAt(product.sizes, _sizeIndex)?.label,
      color: _optionAt(product.colors, _colorIndex),
    );
    if (!context.mounted || result == null) return;
    switch (result) {
      case NegotiateOfferSent(:final amount):
        // Only send variant ids the product actually offers; both are optional
        // on `/api/bid`. The BlocListener toasts the outcome.
        bloc.add(BidSubmitted(
          price: amount,
          sizeId: sizeId,
          colorId: colorId,
        ));
      case NegotiateCheckout():
        _comingSoon(context);
    }
  }

  /// Turns away an Add-to-Cart / Buy-Now tap while an axis the product varies
  /// by is still unpicked — a line with a null size or colour is one the
  /// warehouse can't fill. Reveals the message under the selector that's
  /// missing, and says the same thing in a toast because the selectors can sit
  /// off-screen behind the footer.
  bool _ensureVariantsPicked(BuildContext context, ProductDetails product) {
    final needsColor = _colorMissing(product);
    final needsSize = _sizeMissing(product);
    if (!needsColor && !needsSize) return true;
    setState(() => _showVariantErrors = true);
    AppToast.error(
      context,
      context.tr(switch ((needsColor, needsSize)) {
        (true, true) => LocaleKeys.pleaseSelectColorAndSize,
        (true, false) => LocaleKeys.pleaseSelectColor,
        _ => LocaleKeys.pleaseSelectSize,
      }),
    );
    return false;
  }

  /// Adds the selected variant to the cart. Open to guests — their cart lives
  /// on the device until they sign in, so no auth gate here.
  ///
  /// The line carries the product's own display data (name, thumbnail, price)
  /// because a guest cart has no product lookup to render from.
  Future<void> _addToCart(BuildContext context, ProductDetails product) async {
    if (!_ensureVariantsPicked(context, product)) return;
    final cart = context.read<CartCubit>();
    final added = await cart.add(
      CartItem(
        productId: product.id,
        name: product.name,
        thumbnail: product.images.isEmpty ? '' : product.images.first,
        price: product.effectivePrice,
        originalPrice: product.price,
        sizeId: _optionId(product.sizes, _sizeIndex, (s) => s.id),
        colorId: _optionId(product.colors, _colorIndex, (c) => c.id),
      ),
    );
    if (!context.mounted || !added) return;
    AppToast.success(context, context.tr(LocaleKeys.addedToCart));
  }

  void _comingSoon(BuildContext context) {
    AppToast.info(context, context.tr(LocaleKeys.comingSoon));
  }
}

/// Id of the option at [index], or null when nothing is picked / the list is
/// empty / the index is out of range / the option carries no id.
int? _optionId<T>(List<T> options, int? index, int? Function(T) id) {
  final option = _optionAt(options, index);
  return option == null ? null : id(option);
}

/// The option at [index], or null when nothing is picked / the list is empty /
/// the index is out of range.
T? _optionAt<T>(List<T> options, int? index) =>
    index != null && index >= 0 && index < options.length
    ? options[index]
    : null;

/// Footer shown when the product has no stock — a full-width, height-50
/// "Out Of Stock" pill that replaces the Add-to-Cart / Buy-Now actions.
class _OutOfStockBar extends StatelessWidget {
  const _OutOfStockBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        context.r(16),
        context.r(12),
        context.r(16),
        context.r(12) + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Container(
        height: context.r(50),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(context.r(14)),
        ),
        child: Text(
          context.tr(LocaleKeys.outOfStock),
          style: context.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.product,
    required this.colorIndex,
    required this.sizeIndex,
    required this.colorError,
    required this.sizeError,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.onOpenNegotiate,
  });

  final ProductDetails product;

  /// Picked chips, null while the customer hasn't chosen on that axis.
  final int? colorIndex;
  final int? sizeIndex;

  /// Show the "please pick one" message under that selector — set once a CTA
  /// has been turned away for it.
  final bool colorError;
  final bool sizeError;

  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onSizeSelected;

  /// Tapped the negotiate card — opens the "Price Negotiate" sheet.
  final VoidCallback onOpenNegotiate;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    // The banner and negotiate card follow the customer's size/colour pick, so
    // the shown offer state matches the variant they're looking at.
    final bid = product.bidForVariant(
      sizeId: _optionId(product.sizes, sizeIndex, (s) => s.id),
      colorId: _optionId(product.colors, colorIndex, (c) => c.id),
    );
    // Favorites belong to an account, so a guest always sees the heart empty —
    // same as the cards' [ProductFavoriteButton].
    final isAuthenticated = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.isAuthenticated,
    );
    final isFavorite =
        isAuthenticated &&
        context.select<FavoritesCubit, bool>(
          (cubit) => cubit.isFavorite(product.id),
        );

    return ListView(
      padding: context.edgeAll(16),
      physics: ClampingScrollPhysics(),
      children: [
        ProductImageCarousel(
          images: product.images,
          discountPercentage: product.hasDiscount
              ? product.discountPercentage
              : 0,
          // An accepted offer recolours the badge green, matching the banner
          // below and signalling the price now shown is the agreed one.
          badgeColor: bid?.isApproved == true ? AppColors.success : null,
          isFavorite: isFavorite,
          // A guest gets the sign-in sheet instead of a toggle: the favorite
          // has nowhere to be saved until there's an account behind it.
          onToggleFavorite: () => context.requireAuth(() {
            context.read<FavoritesCubit>().toggle(product.id);
            isFavorite
                ? AppToast.error(
                    context,
                    context.tr(LocaleKeys.itemRemovedFromWishlist),
                    icon: Icons.delete_outline_rounded,
                  )
                : AppToast.success(
                    context,
                    context.tr(LocaleKeys.itemAddedToWishlist),
                    icon: Icons.favorite_rounded,
                  );
          }),
        ),
        context.gapH(16),
        Text(
          product.name,
          style: context.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (product.subtitle.isNotEmpty) ...[
          context.gapH(2),
          Text(
            product.subtitle,
            style: context.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
        context.gapH(10),
        _RatingRow(rating: product.rating, totalSold: product.totalSold),
        context.gapH(12),
        _PriceRow(product: product, currency: currency),
        if (product.estimatedDeliveryTime.isNotEmpty) ...[
          context.gapH(8),
          _DeliveryRow(days: product.estimatedDeliveryTime),
        ],
        // Negotiation is only offered on bidable products: the status of the
        // customer's last offer, then the offer panel itself.
        if (product.isBidable) ...[
          if (bid?.status != null) ...[
            context.gapH(12),
            BidStatusBanner(bid: bid!),
          ],
          context.gapH(12),
          NegotiateOfferCard(bid: bid, onTap: onOpenNegotiate),
        ],
        if (product.colors.isNotEmpty) ...[
          context.gapH(20),
          _SectionTitle(context.tr(LocaleKeys.color)),
          context.gapH(12),
          ProductColorSelector(
            colors: product.colors,
            selectedIndex: colorIndex,
            onSelected: onColorSelected,
          ),
          if (colorError) _VariantError(context.tr(LocaleKeys.pleaseSelectColor)),
        ],
        if (product.sizes.isNotEmpty) ...[
          context.gapH(20),
          _SectionTitle(context.tr(LocaleKeys.size)),
          context.gapH(12),
          ProductSizeSelector(
            sizes: product.sizes,
            selectedIndex: sizeIndex,
            onSelected: onSizeSelected,
          ),
          if (sizeError) _VariantError(context.tr(LocaleKeys.pleaseSelectSize)),
        ],
        context.gapH(20),
        ProductInfoTabs(
          description: product.description,
          reviews: product.reviews,
        ),
        context.gapH(24),
        SimilarProductsSection(
          products: product.similarProducts,
          onProductTap: (p) =>
              context.push(AppRoutes.productDetails, extra: p.id),
        ),
      ],
    );
  }
}

/// Inline validation line under a variant selector the customer skipped.
class _VariantError extends StatelessWidget {
  const _VariantError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.r(8)),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: context.r(16),
            color: AppColors.error,
          ),
          context.gapW(6),
          Expanded(
            child: Text(
              message,
              style: context.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.totalSold});

  final double rating;
  final int totalSold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          size: context.r(20),
          color: AppColors.primaryBronze,
        ),
        context.gapW(4),
        Text(
          rating.toStringAsFixed(1),
          style: context.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        context.gapW(10),
        Text(
          '${context.tr(LocaleKeys.sold)} ($totalSold)',
          style: context.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product, required this.currency});

  final ProductDetails product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    // An accepted offer replaces the shown price, so the list price is struck
    // through even on products that carry no discount of their own.
    final showOriginal =
        product.hasDiscount || product.effectivePrice < product.price;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${product.effectivePrice.toStringAsFixed(2)} $currency',
          style: context.titleLarge?.copyWith(color: AppColors.textPrimaryGold),
        ),
        if (showOriginal) ...[
          context.gapW(10),
          Padding(
            padding: EdgeInsets.only(bottom: context.r(2)),
            child: Text(
              '${product.price.toStringAsFixed(2)} $currency',
              style: context.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({required this.days});

  final String days;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Assets.icons.truckIcn.svg(width: context.r(20), height: context.r(20)),
        context.gapW(8),
        // The API returns this already-localized (e.g. "3 أيام"), so show it as-is.
        Text(
          days,
          style: context.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
