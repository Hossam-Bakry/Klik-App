import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../../../catalog/presentation/widgets/product_card.dart';
import 'section_header.dart';

/// "Popular Products" — a horizontal carousel of [ProductCard]s fed by the
/// shared [CatalogBloc]. Handles the loading / failure / success states.
class HomeProductsSection extends StatelessWidget {
  const HomeProductsSection({super.key, this.onSeeAll});

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.edgeHorizontal(16),
          child: SectionHeader(
            title: context.tr(LocaleKeys.popularProducts),
            onSeeAll: onSeeAll,
          ),
        ),
        context.gapH(12),
        SizedBox(
          height: context.r(250),
          child: BlocBuilder<CatalogBloc, CatalogState>(
            builder: (context, state) {
              switch (state.status) {
                case CatalogStatus.initial:
                case CatalogStatus.loading:
                  return const Center(child: CircularProgressIndicator());

                case CatalogStatus.failure:
                  return Center(
                    child: Text(
                      state.errorMessage ?? context.tr(LocaleKeys.somethingWentWrong),
                      textAlign: TextAlign.center,
                    ),
                  );

                case CatalogStatus.success:
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: context.edgeHorizontal(16),
                    itemCount: state.products.length,
                    separatorBuilder: (_, _) => context.gapW(12),
                    itemBuilder: (context, i) => SizedBox(
                      width: context.r(160),
                      child: ProductCard(product: state.products[i]),
                    ),
                  );
              }
            },
          ),
        ),
      ],
    );
  }
}
