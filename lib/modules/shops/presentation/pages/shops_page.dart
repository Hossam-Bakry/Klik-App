import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../products/domain/entities/products_filter.dart';
import '../../../home/domain/entities/shop_item.dart';
import '../bloc/shops_bloc.dart';
import '../widgets/shop_grid_tile.dart';

/// All shops, reached from the home "Shops" section's "See all". A search
/// field filters the grid locally by name — it doesn't hit the network.
class ShopsPage extends StatefulWidget {
  const ShopsPage({super.key});

  @override
  State<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends State<ShopsPage> {
  static const _crossAxisCount = 3;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<ShopsBloc>();
        if (bloc.state.status == ShopsStatus.failure) {
          bloc.add(const ShopsRefreshed());
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
            context.tr(LocaleKeys.shops),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<ShopsBloc, ShopsState>(
          builder: (context, state) {
            if (state.status == ShopsStatus.failure) {
              return ErrorView(
                message:
                    state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: () =>
                    context.read<ShopsBloc>().add(const ShopsStarted()),
              );
            }

            final loading = state.isLoading;
            final query = _query.trim().toLowerCase();
            final filtered = query.isEmpty
                ? state.shops
                : state.shops
                      .where((s) => s.name.toLowerCase().contains(query))
                      .toList();

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<ShopsBloc>().add(const ShopsRefreshed()),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: context.edgeAll(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.r(30)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: context.r(8),
                                offset: Offset(0, context.r(2)),
                              ),
                            ],
                          ),
                          child: AppTextField.search(
                            controller: _searchController,
                            hint: context.tr(LocaleKeys.searchHint),
                            onChanged: (value) =>
                                setState(() => _query = value),
                          ),
                        ),
                      ),
                      // context.gapW(12),
                      // _FilterButton(onTap: () => _comingSoon(context)),
                    ],
                  ),
                  context.gapH(20),
                  if (loading)
                    const _LoadingGrid(crossAxisCount: _crossAxisCount)
                  else if (filtered.isEmpty)
                    EmptyView(message: context.tr(LocaleKeys.noItemsYet))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        mainAxisSpacing: context.r(16),
                        crossAxisSpacing: context.r(16),
                        childAspectRatio: shopTileAspectRatio,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => ShopGridTile(
                        shop: filtered[i],
                        onTap: () => _openShop(context, filtered[i]),
                      ),
                    ),
                  context.gapH(100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openShop(BuildContext context, ShopItem shop) {
    context.push(
      AppRoutes.products,
      extra: ProductsFilter(shopId: shop.id, title: shop.name),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(30)),
      child: Container(
        width: context.r(48),
        height: context.r(48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: context.r(8),
              offset: Offset(0, context.r(2)),
            ),
          ],
        ),
        child: Icon(Icons.tune_rounded, color: AppColors.primary, size: context.r(22)),
      ),
    );
  }
}

/// Placeholder tile grid shown while the shop list loads — logo card plus a
/// name bar, mirroring [ShopGridTile] so the real grid doesn't shift in.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({required this.crossAxisCount});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final bone = BoxDecoration(
      color: AppColors.textSecondary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(context.r(16)),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: context.r(16),
        crossAxisSpacing: context.r(16),
        childAspectRatio: shopTileAspectRatio,
      ),
      itemCount: 9,
      itemBuilder: (context, i) => Column(
        children: [
          Expanded(child: DecoratedBox(decoration: bone)),
          context.gapH(6),
          Container(
            height: context.r(10),
            width: double.infinity,
            decoration: bone,
          ),
        ],
      ),
    );
  }
}

