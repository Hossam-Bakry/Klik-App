import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/product_details.dart';
import '../bloc/product_bloc.dart';
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
  int _colorIndex = 0;
  int _sizeIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                  state.errorMessage ?? context.tr(LocaleKeys.somethingWentWrong),
              onRetry: () => _reload(context),
            );
          }
          if (state.isLoading || state.product == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _Content(
            product: state.product!,
            colorIndex: _colorIndex,
            sizeIndex: _sizeIndex,
            onColorSelected: (i) => setState(() => _colorIndex = i),
            onSizeSelected: (i) => setState(() => _sizeIndex = i),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final product = state.product;
          if (product == null) return const SizedBox.shrink();
          // Out of stock: swap the CTAs for a disabled "Out Of Stock" banner.
          if (product.isOutOfStock) return const _OutOfStockBar();
          return ProductBottomBar(
            onAddToCart: () => _comingSoon(context),
            onBuyNow: () => _comingSoon(context),
          );
        },
      ),
    );
  }

  void _reload(BuildContext context) {
    final id = context.read<ProductBloc>().state.product?.id;
    if (id != null) context.read<ProductBloc>().add(ProductDetailsRequested(id));
  }

  void _comingSoon(BuildContext context) {
    AppToast.info(context, context.tr(LocaleKeys.comingSoon));
  }
}

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
    required this.onColorSelected,
    required this.onSizeSelected,
  });

  final ProductDetails product;
  final int colorIndex;
  final int sizeIndex;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onSizeSelected;

  @override
  Widget build(BuildContext context) {
    final currency = context.tr(LocaleKeys.currencyKwd);
    final isFavorite = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.isFavorite(product.id),
    );

    return ListView(
      padding: context.edgeAll(16),
      children: [
        ProductImageCarousel(
          images: product.images,
          discountPercentage: product.hasDiscount ? product.discountPercentage : 0,
          isFavorite: isFavorite,
          onToggleFavorite: () =>
              context.read<FavoritesCubit>().toggle(product.id),
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
        if (product.colors.isNotEmpty) ...[
          context.gapH(20),
          _SectionTitle(context.tr(LocaleKeys.color)),
          context.gapH(12),
          ProductColorSelector(
            colors: product.colors,
            selectedIndex: colorIndex,
            onSelected: onColorSelected,
          ),
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
        ],
        context.gapH(20),
        ProductInfoTabs(description: product.description, reviews: product.reviews),
        context.gapH(24),
        SimilarProductsSection(
          products: product.similarProducts,
          onProductTap: (p) => context.push(AppRoutes.productDetails, extra: p.id),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: context.titleSmall?.copyWith(fontWeight: FontWeight.bold));
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
        Icon(Icons.star_rounded, size: context.r(20), color: AppColors.primaryBronze),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${product.effectivePrice.toStringAsFixed(2)} $currency',
          style: context.titleLarge?.copyWith(
            color: AppColors.textPrimaryGold,
          ),
        ),
        if (product.hasDiscount) ...[
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

