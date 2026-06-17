import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_products_section.dart';
import '../widgets/home_promo_banner.dart';
import '../widgets/home_search_field.dart';

/// Home tab: a vertically scrolling feed of self-contained sections (greeting,
/// search, promo banner, categories, popular products). Each section is its own
/// widget so they can be reordered, reused, or fed independently. Reads the
/// shared [CatalogBloc] provided by the host layout.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => context.read<CatalogBloc>().add(const CatalogRefreshed()),
          child: ListView(
            // Bottom padding clears the floating curved nav bar.
            padding: EdgeInsets.only(top: context.r(8), bottom: context.r(120)),
            children: [
              Padding(
                padding: context.edgeHorizontal(16),
                child: const HomeAppBar(),
              ),
              context.gapH(16),
              Padding(
                padding: context.edgeHorizontal(16),
                child: const HomeSearchField(),
              ),
              context.gapH(20),
              Padding(
                padding: context.edgeHorizontal(16),
                child: const HomePromoBanner(),
              ),
              context.gapH(24),
              const HomeCategoriesSection(),
              context.gapH(24),
              const HomeProductsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
