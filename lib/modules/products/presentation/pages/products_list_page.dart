import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/product_card_item.dart';
import '../../../home/domain/entities/home_product.dart';
import '../../../home/presentation/widgets/offer_product_card.dart';
import '../bloc/products_bloc.dart';
import '../widgets/products_filter_sheet.dart';

/// How the listing renders its items.
enum ProductsListLayout {
  /// Two-column card grid — the default listing.
  grid,

  /// Full-width offer rows with the negotiate call-to-action.
  offers,
}

/// Reusable products listing, driven entirely by the [ProductsBloc]'s filter.
/// Reached from Shops (shop_id), Categories (category/sub_category_id) and the
/// home "Best deals" see-all (sort=popular). Paginates on scroll, filters via
/// the search field and the filter sheet.
///
/// Two cases: the default pushed page, and [ProductsListPage.offersTab] for the
/// shell's Negotiation destination.
class ProductsListPage extends StatefulWidget {
  const ProductsListPage({super.key, this.autofocusSearch = false})
    : layout = ProductsListLayout.grid,
      isTab = false;

  /// Hosted by the main shell's Negotiation tab rather than pushed: offer-row
  /// layout, no back button, and bottom padding for the floating nav bar.
  const ProductsListPage.offersTab({super.key})
    : autofocusSearch = false,
      layout = ProductsListLayout.offers,
      isTab = true;

  /// Autofocus the search field on open, raising the keyboard immediately.
  /// Set when the page is reached from the home search field so the user can
  /// start typing without a second tap.
  final bool autofocusSearch;

  final ProductsListLayout layout;

  /// Rendered as a bottom-nav destination (no route to pop back to).
  final bool isTab;

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  final _scrollController = ScrollController();
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<ProductsBloc>().state.filter.search ?? '',
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Prefetch the next page as the user nears the bottom.
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - context.r(400)) {
      context.read<ProductsBloc>().add(const ProductsLoadMore());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final bloc = context.read<ProductsBloc>();
      final trimmed = value.trim();
      final next = trimmed.isEmpty
          ? bloc.state.filter.copyWith(clearSearch: true)
          : bloc.state.filter.copyWith(search: trimmed);
      bloc.add(ProductsFilterChanged(next));
    });
  }

  Future<void> _openFilters() async {
    final bloc = context.read<ProductsBloc>();
    final result = await showProductsFilterSheet(
      context,
      filter: bloc.state.filter,
      categories: bloc.state.categories,
      brands: bloc.state.brands,
    );
    if (result != null) bloc.add(ProductsFilterChanged(result));
  }

  /// The item sliver for the active [ProductsListPage.layout]: a two-column
  /// card grid, or full-width offer rows for the Negotiation tab.
  Widget _itemsSliver(BuildContext context, List<HomeProduct> products) {
    void openDetails(HomeProduct product) =>
        context.push(AppRoutes.productDetails, extra: product.id);

    if (widget.layout == ProductsListLayout.offers) {
      return SliverList.separated(
        itemCount: products.length,
        separatorBuilder: (_, _) => context.gapH(12),
        itemBuilder: (context, i) => OfferProductCard(
          product: products[i],
          onTap: () => openDetails(products[i]),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: context.r(12),
        crossAxisSpacing: context.r(12),
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, i) => ProductCardItem(
          product: products[i],
          onTap: () => openDetails(products[i]),
        ),
        childCount: products.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = context.select<ProductsBloc, String?>(
      (b) => b.state.filter.title,
    );
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<ProductsBloc>();
        if (bloc.state.status == ProductsStatus.failure) {
          bloc.add(const ProductsRefreshed());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: !widget.isTab,
          leading: widget.isTab
              ? null
              : const BackButton(color: AppColors.textPrimary),
          title: Text(
            title?.isNotEmpty == true
                ? title!
                : context.tr(LocaleKeys.products),
            style: context.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: context.edgeSymmetric(horizontal: 16, vertical: 12),
              child: Row(
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
                        onChanged: _onSearchChanged,
                        autofocus: widget.autofocusSearch,
                      ),
                    ),
                  ),
                  context.gapW(12),
                  BlocSelector<ProductsBloc, ProductsState, bool>(
                    selector: (s) => s.filter.hasActiveRefinements,
                    builder: (context, active) =>
                        _FilterButton(active: active, onTap: _openFilters),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state.status == ProductsStatus.failure &&
                      state.products.isEmpty) {
                    return ErrorView(
                      message:
                          state.errorMessage ??
                          context.tr(LocaleKeys.somethingWentWrong),
                      onRetry: () => context.read<ProductsBloc>().add(
                        ProductsStarted(state.filter),
                      ),
                    );
                  }
                  if (state.isLoading) {
                    return _SkeletonItems(layout: widget.layout);
                  }
                  if (state.products.isEmpty) {
                    // Search screen before the first query → prompt to type;
                    // otherwise a genuine "no results" for the active query.
                    return EmptyView(
                      image: Assets.images.emptyCartImg.image(
                        width: context.w(220),
                      ),
                      message: context.tr(
                        state.isAwaitingQuery
                            ? LocaleKeys.searchProductsPrompt
                            : LocaleKeys.noItemsYet,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => context.read<ProductsBloc>().add(
                      const ProductsRefreshed(),
                    ),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: context.edgeAll(16),
                          sliver: _itemsSliver(context, state.products),
                        ),
                        SliverToBoxAdapter(
                          child: _PaginationFooter(
                            state: state,
                            onRetry: () => context.read<ProductsBloc>().add(
                              const ProductsLoadMore(),
                            ),
                          ),
                        ),
                        // As a tab, clear the floating curved nav bar.
                        if (widget.isTab)
                          SliverToBoxAdapter(
                            child: SizedBox(height: context.r(100)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder items shown under a [Skeletonizer] while the first page loads —
/// same layout as the real list so the transition doesn't jump.
class _SkeletonItems extends StatelessWidget {
  const _SkeletonItems({required this.layout});

  final ProductsListLayout layout;

  static const _placeholder = HomeProduct(
    id: 0,
    name: 'Product name',
    thumbnail: '',
    price: 100,
    discountPrice: 80,
    discountPercentage: 20,
    rating: 4.5,
    totalSold: 100,
    quantity: 1,
    isFavorite: false,
    isBidable: false,
    shopName: 'Shop',
    estimatedDeliveryTime: '2',
  );

  /// Offer rows only render the negotiate footer for bidable products, so the
  /// bones need it too — otherwise the real cards are taller than the skeleton.
  static const _bidablePlaceholder = HomeProduct(
    id: 0,
    name: 'Product name',
    thumbnail: '',
    price: 100,
    discountPrice: 80,
    discountPercentage: 20,
    rating: 4.5,
    totalSold: 100,
    quantity: 1,
    isFavorite: false,
    isBidable: true,
    shopName: 'Shop',
    estimatedDeliveryTime: '2',
  );

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: layout == ProductsListLayout.offers
          ? ListView.separated(
              padding: context.edgeAll(16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => context.gapH(12),
              itemBuilder: (context, i) =>
                  const OfferProductCard(product: _bidablePlaceholder),
            )
          : GridView.builder(
              padding: context.edgeAll(16),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: context.r(12),
                crossAxisSpacing: context.r(12),
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, i) =>
                  const ProductCardItem(product: _placeholder),
            ),
    );
  }
}

/// Bottom-of-list slot: a spinner while paginating, a retry row on load-more
/// failure, or empty space otherwise.
class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({required this.state, required this.onRetry});

  final ProductsState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return Padding(
        padding: context.edgeSymmetric(vertical: 16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.loadMoreError) {
      return Padding(
        padding: context.edgeSymmetric(vertical: 8),
        child: Center(
          child: AppButton.text(
            label: context.tr(LocaleKeys.couldNotLoadMore),
            foregroundColor: AppColors.primary,
            onPressed: onRetry,
          ),
        ),
      );
    }
    return SizedBox(height: context.r(16));
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, this.onTap});

  final bool active;
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.tune_rounded,
              color: AppColors.primary,
              size: context.r(22),
            ),
            if (active)
              Positioned(
                top: context.r(-2),
                right: context.r(-2),
                child: Container(
                  width: context.r(8),
                  height: context.r(8),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

