import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../modules/auth/presentation/bloc/auth_bloc.dart';
import '../../modules/auth/presentation/widgets/auth_prompt.dart';
import '../extensions/context_extensions.dart';
import '../favorites/presentation/favorites_cubit.dart';
import '../theme/app_colors.dart';

/// Favorite toggle icon for a product card, wired to the shared
/// [FavoritesCubit] so tapping it here reflects on every other card showing
/// the same product (home, categories, product details, similar products).
///
/// Guests always see the unfavorited state (favorites aren't persisted for
/// them) and tapping it prompts sign-in instead of toggling.
class ProductFavoriteButton extends StatelessWidget {
  const ProductFavoriteButton({
    super.key,
    required this.productId,
    this.selectedColor = AppColors.error,
    this.unselectedColor = AppColors.surface,
  });

  final int productId;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.select<AuthBloc, bool>(
      (bloc) => bloc.state.isAuthenticated,
    );
    final isFavorite =
        isAuthenticated &&
        context.select<FavoritesCubit, bool>(
          (cubit) => cubit.isFavorite(productId),
        );
    return GestureDetector(
      onTap: () => context.requireAuth(
        () => context.read<FavoritesCubit>().toggle(productId),
      ),
      child: Container(
        width: context.r(26),
        height: context.r(26),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isFavorite ? selectedColor : unselectedColor,
          shape: BoxShape.circle,
        ),
        child:
            (isFavorite
                    ? Assets.icons.selectedFavoriteIcn
                    : Assets.icons.unSelectedFavoriteIcn)
                .svg(),
      ),
    );
  }
}
