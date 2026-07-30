import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/favorites/presentation/favorites_cubit.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../home/domain/entities/home_product.dart';
import '../bloc/wishlist_bloc.dart';
import '../widgets/wishlist_product_card.dart';

/// The signed-in user's favorite products (`GET /api/favorite-products`),
/// reached from Profile → Wishlist. Unfavoriting a card removes it from the
/// list immediately (the global [FavoritesCubit] drives visibility).
class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<WishlistBloc>();
        if (bloc.state.status == WishlistStatus.failure) {
          bloc.add(const WishlistRefreshed());
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
            context.tr(LocaleKeys.wishlist),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<WishlistBloc, WishlistState>(
          builder: (context, state) {
            if (state.status == WishlistStatus.failure) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: () =>
                    context.read<WishlistBloc>().add(const WishlistStarted()),
              );
            }
            if (state.isLoading) {
              return const _SkeletonList();
            }

            // Hide any product the user just unfavorited (still in the loaded
            // list, but dropped from the global favorites set).
            final favorites = context.watch<FavoritesCubit>().state;
            final visible = state.products
                .where((p) => favorites.contains(p.id))
                .toList();

            if (visible.isEmpty) {
              return EmptyView(
                image: Assets.images.emptyWishlistImg.image(
                  width: context.w(220),
                ),
                message: context.tr(LocaleKeys.noItemsYet),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<WishlistBloc>().add(const WishlistRefreshed()),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.edge(left: 16, right: 16, top: 8, bottom: 24),
                itemCount: visible.length,
                separatorBuilder: (_, _) => context.gapH(12),
                itemBuilder: (context, i) => WishlistProductCard(
                  product: visible[i],
                  onTap: () => context.push(
                    AppRoutes.productDetails,
                    extra: visible[i].id,
                  ),
                  onAdd: () => _comingSoon(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    AppToast.info(context, context.tr(LocaleKeys.comingSoon));
  }
}

/// Placeholder rows shown under a [Skeletonizer] while favorites load.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  static const _placeholder = HomeProduct(
    id: 0,
    name: 'Samsung washing machine',
    thumbnail: '',
    price: 19,
    discountPrice: 0,
    discountPercentage: 0,
    rating: 4.5,
    totalSold: 113,
    quantity: 1,
    isFavorite: true,
    isBidable: false,
    shopName: 'Shop',
    estimatedDeliveryTime: '2',
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
            const WishlistProductCard(product: _placeholder),
      ),
    );
  }
}
