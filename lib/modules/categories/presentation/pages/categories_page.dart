import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../products/domain/entities/products_filter.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';
import '../widgets/category_grid_tile.dart';
import '../widgets/sub_categories_panel.dart';

/// Categories tab: a grid of all top-level categories. Tapping a tile expands
/// its subcategories inline right below its row; a category with none
/// navigates straight to its products instead (see [CategoriesBloc]). The
/// search field filters the grid locally by name — it doesn't hit the network.
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
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
        final bloc = context.read<CategoriesBloc>();
        if (bloc.state.status == CategoriesStatus.failure) {
          bloc.add(const CategoriesRefreshed());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: BlocConsumer<CategoriesBloc, CategoriesState>(
            listenWhen: (previous, current) =>
                previous.navigationToken != current.navigationToken,
            listener: (context, state) {
              final category = state.navigateToCategory;
              if (category != null) {
                _openProducts(
                  context,
                  ProductsFilter(
                    categoryId: category.id,
                    title: category.name,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.status == CategoriesStatus.failure) {
                return ErrorView(
                  message:
                      state.errorMessage ??
                      context.tr(LocaleKeys.somethingWentWrong),
                  onRetry: () => context.read<CategoriesBloc>().add(
                    const CategoriesStarted(),
                  ),
                );
              }

              final loading =
                  state.status == CategoriesStatus.initial ||
                  state.status == CategoriesStatus.loading;

              final query = _query.trim().toLowerCase();
              final filtered = loading
                  ? Category.placeholder()
                  : query.isEmpty
                  ? state.categories
                  : state.categories
                        .where((c) => c.name.toLowerCase().contains(query))
                        .toList();

              return RefreshIndicator(
                onRefresh: () async => context.read<CategoriesBloc>().add(
                  const CategoriesRefreshed(),
                ),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: context.edgeAll(16),
                  children: [
                    Text(
                      context.tr(LocaleKeys.categories),
                      textAlign: TextAlign.center,
                      style: context.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    context.gapH(16),
                    Container(
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
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                    context.gapH(20),
                    if (filtered.isEmpty)
                      EmptyView(message: context.tr(LocaleKeys.noItemsYet))
                    else
                      Skeletonizer(
                        enabled: loading,
                        child: Column(
                          children: _buildRows(
                            context,
                            state,
                            filtered,
                            loading: loading,
                          ),
                        ),
                      ),
                    context.gapH(100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Chunks [categories] (already filtered by the search query) into rows of
  /// [_crossAxisCount]. Every chunk always gets an (animated) subcategories
  /// slot right after its row, so toggling
  /// [CategoriesState.expandedCategoryId] animates open/closed instead of
  /// popping the panel in and out.
  List<Widget> _buildRows(
    BuildContext context,
    CategoriesState state,
    List<Category> categories, {
    bool loading = false,
  }) {
    final rows = <Widget>[];

    for (var i = 0; i < categories.length; i += _crossAxisCount) {
      final chunk = categories.skip(i).take(_crossAxisCount).toList();
      final expanded = chunk.any((c) => c.id == state.expandedCategoryId);

      rows.add(
        Row(
          children: [
            for (final category in chunk)
              Expanded(
                child: CategoryGridTile(
                  category: category,
                  selected: state.expandedCategoryId == category.id,
                  onTap: loading
                      ? () {}
                      : () => context.read<CategoriesBloc>().add(
                          CategoryTapped(category),
                        ),
                ),
              ),
            for (var j = chunk.length; j < _crossAxisCount; j++)
              const Expanded(child: SizedBox()),
          ],
        ),
      );

      rows.add(
        _AnimatedSubCategories(
          key: ValueKey('$i-${chunk.first.id}'),
          expanded: expanded,
          panel: SubCategoriesPanel(
            loading: state.subCategoriesStatus == SubCategoriesStatus.loading,
            subCategories:
                state.subCategoriesCache[state.expandedCategoryId] ?? const [],
            onTap: (subCategory) => _openProducts(
              context,
              ProductsFilter(
                subCategoryId: subCategory.id,
                title: subCategory.name,
              ),
            ),
          ),
        ),
      );

      rows.add(context.gapH(16));
    }

    return rows;
  }

  void _openProducts(BuildContext context, ProductsFilter filter) {
    context.push(AppRoutes.products, extra: filter);
  }
}

/// Animates the subcategories panel open/closed with a combined fade + resize
/// (Flutter's standard expand/collapse idiom) instead of popping it in place.
class _AnimatedSubCategories extends StatelessWidget {
  const _AnimatedSubCategories({
    super.key,
    required this.expanded,
    required this.panel,
  });

  final bool expanded;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 260),
      sizeCurve: Curves.easeInOut,
      firstCurve: Curves.easeIn,
      secondCurve: Curves.easeIn,
      crossFadeState: expanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Padding(
        padding: EdgeInsets.only(top: context.r(8)),
        child: panel,
      ),
    );
  }
}

