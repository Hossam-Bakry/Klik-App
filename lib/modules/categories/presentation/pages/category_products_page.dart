import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/product_card_item.dart';
import '../bloc/category_products_bloc.dart';

/// Products for a leaf category (one with no subcategories), reached from
/// [CategoriesPage] when a tapped category resolves to an empty subcategory
/// list.
class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<CategoryProductsBloc>();
        if (bloc.state.status == CategoryProductsStatus.failure) {
          bloc.add(CategoryProductsRefreshed(categoryId));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(title: Text(categoryName)),
        body: BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
          builder: (context, state) {
            switch (state.status) {
              case CategoryProductsStatus.initial:
              case CategoryProductsStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case CategoryProductsStatus.failure:
                return _ErrorView(
                  message:
                      state.errorMessage ??
                      context.tr(LocaleKeys.somethingWentWrong),
                  onRetry: () => context.read<CategoryProductsBloc>().add(
                    CategoryProductsRequested(categoryId),
                  ),
                );

              case CategoryProductsStatus.success:
                if (state.products.isEmpty) {
                  return Center(child: Text(context.tr(LocaleKeys.noItemsYet)));
                }
                return RefreshIndicator(
                  onRefresh: () async => context
                      .read<CategoryProductsBloc>()
                      .add(CategoryProductsRefreshed(categoryId)),
                  child: GridView.builder(
                    padding: context.edgeAll(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: context.r(12),
                      crossAxisSpacing: context.r(12),
                      childAspectRatio: 0.85,
                    ),
                    itemCount: state.products.length,
                    itemBuilder: (context, i) => ProductCardItem(
                      product: state.products[i],
                      onTap: () => context.push(
                        AppRoutes.productDetails,
                        extra: state.products[i].id,
                      ),
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.edgeAll(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: context.r(48),
              color: AppColors.textSecondary,
            ),
            context.gapH(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.sp(14),
              ),
            ),
            context.gapH(16),
            AppButton.text(
              label: context.tr(LocaleKeys.retry),
              foregroundColor: AppColors.primary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
