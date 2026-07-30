import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/catalog_bloc.dart';
import '../widgets/product_card.dart';

/// Pure consumer — its [CatalogBloc] is provided at the route (see
/// AppRouter). Reads state via context; never constructs the bloc itself.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(LocaleKeys.storeTitle)),
        actions: [
          IconButton(
            tooltip: context.tr(LocaleKeys.signOut),
            icon: const Icon(Icons.logout),
            // Logging out flips AuthStatus → unauthenticated, and the router
            // guard automatically redirects to /login.
            onPressed: () =>
                sl<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          switch (state.status) {
            case CatalogStatus.initial:
            case CatalogStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case CatalogStatus.failure:
              return ErrorView(
                message: state.errorMessage ??
                    context.tr(LocaleKeys.somethingWentWrong),
                onRetry: () =>
                    context.read<CatalogBloc>().add(const CatalogStarted()),
              );

            case CatalogStatus.success:
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CatalogBloc>().add(const CatalogRefreshed());
                },
                child: GridView.builder(
                  padding: context.edgeAll(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: context.r(12),
                    crossAxisSpacing: context.r(12),
                    childAspectRatio: 0.62,
                  ),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: state.products[index]);
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

