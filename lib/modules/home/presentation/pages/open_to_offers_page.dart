import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../products/domain/entities/products_filter.dart';
import '../../../products/presentation/bloc/products_bloc.dart';
import '../../../products/presentation/pages/products_list_page.dart';

/// Full "Open to offers" listing: the shell's Negotiation destination (index 2),
/// where the home section's "See all" lands.
///
/// Thin host — it pins the listing to `is_bidable=1` and hands over to the
/// reusable products page, so search (debounced, server-side), the filter sheet
/// and pagination all come for free. The home feed's `bidable_products` is only
/// a preview, so this queries `/api/products` rather than reusing that list.
class OpenToOffersPage extends StatelessWidget {
  const OpenToOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsBloc>()
        ..add(
          ProductsStarted(
            ProductsFilter(
              isBidable: true,
              title: context.tr(LocaleKeys.openToOffers),
            ),
          ),
        ),
      child: const ProductsListPage.offersTab(),
    );
  }
}
