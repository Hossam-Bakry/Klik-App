import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_app/core/widgets/app_text_field.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/connectivity_retry_listener.dart';
import '../../domain/entities/home_feed.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_banners_section.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/just_for_you_section.dart';
import '../widgets/open_to_offers_section.dart';
import '../widgets/shops_section.dart';
import 'just_for_you_page.dart';

/// Home tab: a vertically scrolling feed of self-contained sections, driven by
/// [HomeBloc]. While loading, the sections render against placeholder data
/// wrapped in a [Skeletonizer] so the layout shows shimmering bones.
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onOpenOffers, this.onOpenCategories});

  /// Tapped "See all" on the Open-to-offers section. The shell uses it to
  /// switch to the Negotiation tab (index 2).
  final VoidCallback? onOpenOffers;

  /// Tapped "See all" on the Categories section. The shell uses it to switch
  /// to the Categories tab (index 1).
  final VoidCallback? onOpenCategories;

  @override
  Widget build(BuildContext context) {
    return ConnectivityRetryListener(
      onRestored: () {
        final bloc = context.read<HomeBloc>();
        if (bloc.state.status == HomeStatus.failure) {
          bloc.add(const HomeRefreshed());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              // Hard failure with nothing to show yet → full-screen error.
              if (state.status == HomeStatus.failure && state.feed == null) {
                return _ErrorView(
                  message: state.errorMessage,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeStarted()),
                );
              }

              final loading = state.isLoading;
              final feed = loading ? HomeFeed.placeholder() : state.feed!;

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<HomeBloc>().add(const HomeRefreshed()),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // Bottom padding clears the floating curved nav bar.
                  padding: EdgeInsets.only(
                    top: context.r(8),
                    bottom: context.r(120),
                  ),
                  children: [
                    Padding(
                      padding: context.edgeHorizontal(16),
                      child: const HomeAppBar(),
                    ),
                    context.gapH(16),
                    Padding(
                      padding: context.edgeHorizontal(16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AppTextField.search(
                          controller: TextEditingController(),
                          hint: context.tr(LocaleKeys.searchHint),
                        ),
                      ),
                    ),
                    context.gapH(20),
                    Skeletonizer(
                      enabled: loading,
                      child: Column(
                        children: [
                          HomeBannersSection(banners: feed.banners),
                          context.gapH(24),
                          HomeCategoriesSection(
                            categories: feed.categories,
                            // Opens the Categories tab (index 1) via the shell.
                            onSeeAll: loading ? null : onOpenCategories,
                          ),
                          context.gapH(24),
                          JustForYouSection(
                            products: feed.justForYou,
                            onSeeAll: loading
                                ? null
                                : () => _open(
                                    context,
                                    JustForYouPage(products: feed.justForYou),
                                  ),
                          ),
                          context.gapH(24),
                          ShopsSection(
                            shops: feed.shops,
                            onSeeAll: loading
                                ? null
                                : () => _open(
                                    context,
                                    JustForYouPage(products: feed.justForYou),
                                  ),
                          ),
                          context.gapH(24),
                          OpenToOffersSection(
                            products: feed.bidableProducts,
                            // Opens the Negotiation tab (index 2) via the shell.
                            onSeeAll: loading ? null : onOpenOffers,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message, required this.onRetry});

  final String? message;
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
              message ?? context.tr(LocaleKeys.somethingWentWrong),
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
