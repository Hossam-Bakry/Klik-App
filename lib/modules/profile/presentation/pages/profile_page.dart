import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';
import '../cubit/current_user_cubit.dart';
import '../widgets/guest_auth_buttons.dart';
import '../widgets/language_selector_tile.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_footer.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_quick_actions.dart';
import '../widgets/profile_section_card.dart';

/// Profile destination (tab index 4): the account hub with quick shortcuts,
/// settings, support links, and sign-out.
///
/// Adapts to [AuthStatus]: a guest sees a trimmed-down page (legal + locale
/// prefs, then Log In / Sign Up — no account-only sections at all, since
/// they'd just prompt sign-in anyway). A signed-in user sees the full set of
/// account sections plus the logout action.
///
/// Name/email/avatar come from the app-wide [CurrentUserCubit], which holds the
/// `GET /api/profile` response for the current session.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(context.tr(LocaleKeys.profileTitle)),
        actions: [
          Padding(
            padding: context.edgeSymmetric(horizontal: 12),
            child: _SupportButton(
              onTap: () => context.push(AppRoutes.support),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (p, c) => p.status != c.status,
          builder: (context, state) {
            final isGuest = state.isGuest;

            // Account-only actions: run when signed in, else prompt sign-in.
            void gated(VoidCallback action) => context.requireAuth(action);

            return ListView(
              padding: context.edge(left: 16, right: 16, top: 8, bottom: 120),
              children: [
                if (isGuest) ...[
                  _legalCard(context),
                  context.gapH(16),
                  _localeCard(context),
                  context.gapH(16),
                  const GuestAuthButtons(),
                  context.gapH(16),
                ] else ...[
                  const _Header(),
                  context.gapH(20),

                  // Quick shortcuts.
                  ProfileSectionCard(
                    padding: context.edgeSymmetric(horizontal: 12, vertical: 16),
                    child: ProfileQuickActions(
                      onOrders: () => gated(() {}),
                      onNegotiation: () =>
                          gated(() => context.push(AppRoutes.negotiations)),
                      onWishlist: () =>
                          gated(() => context.push(AppRoutes.wishlist)),
                    ),
                  ),
                  context.gapH(16),

                  // Notifications & address.
                  ProfileSectionCard(
                    child: Column(
                      children: [
                        ProfileMenuTile(
                          icon: Assets.icons.notificationIcn,
                          title: context.tr(LocaleKeys.notification),
                          trailing: const ProfileTileChevron(),
                          onTap: () => gated(() {}),
                        ),
                        ProfileMenuTile(
                          icon: Assets.icons.locationIcn,
                          title: context.tr(LocaleKeys.manageAddress),
                          trailing: const ProfileTileChevron(),
                          // Opens the Manage Address screen (list / add / delete),
                          // backed by the shared singleton AddressBloc.
                          onTap: () =>
                              gated(() => context.push(AppRoutes.addressList)),
                        ),
                      ],
                    ),
                  ),
                  context.gapH(16),

                  // Locale preferences — available to everyone.
                  _localeCard(context),
                  context.gapH(16),

                  // Account & legal.
                  ProfileSectionCard(
                    child: Column(
                      children: [
                        ProfileMenuTile(
                          icon: Assets.icons.changePasswordIcn,
                          title: context.tr(LocaleKeys.changePassword),
                          trailing: const ProfileTileChevron(),
                          onTap: () => gated(
                            () => context.push(AppRoutes.updatePassword),
                          ),
                        ),
                        ProfileMenuTile(
                          icon: Assets.icons.securityIcn,
                          title: context.tr(LocaleKeys.security),
                          trailing: const ProfileTileChevron(),
                          onTap: () =>
                              gated(() => context.push(AppRoutes.security)),
                        ),
                        ProfileMenuTile(
                          icon: Assets.icons.termsIcn,
                          title: context.tr(LocaleKeys.termsServices),
                          trailing: const ProfileTileChevron(),
                          onTap: () {},
                        ),
                        ProfileMenuTile(
                          icon: Assets.icons.policyIcn,
                          title: context.tr(LocaleKeys.privacyPolicy),
                          trailing: const ProfileTileChevron(),
                          onTap: () {},
                        ),
                        ProfileMenuTile(
                          icon: Assets.icons.logoutIcn,
                          title: context.tr(LocaleKeys.logout),
                          danger: true,
                          // Confirm first; logout flips AuthStatus →
                          // unauthenticated and the user stays in the app as a
                          // guest.
                          onTap: () async {
                            final confirmed =
                                await showLogoutConfirmationDialog(context);
                            if (confirmed) {
                              sl<AuthBloc>().add(const AuthLogoutRequested());
                              if (context.mounted) {
                                AppToast.success(
                                  context,
                                  context.tr(LocaleKeys.loggedOutSuccessfully),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  context.gapH(16),
                ],

                ProfileFooter(
                  onSellWithUs: () {},
                  onTikTok: () {},
                  onInstagram: () {},
                  onFacebook: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Terms & Services / Privacy Policy — shown to guests without the rest of
  /// the account & legal card (change password / security / logout).
  Widget _legalCard(BuildContext context) {
    return ProfileSectionCard(
      child: Column(
        children: [
          ProfileMenuTile(
            icon: Assets.icons.termsIcn,
            title: context.tr(LocaleKeys.termsServices),
            trailing: const ProfileTileChevron(),
            onTap: () {},
          ),
          ProfileMenuTile(
            icon: Assets.icons.policyIcn,
            title: context.tr(LocaleKeys.privacyPolicy),
            trailing: const ProfileTileChevron(),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// Language / Country — available to everyone, guest or signed in.
  Widget _localeCard(BuildContext context) {
    return ProfileSectionCard(
      child: Column(
        children: [
          const LanguageSelectorTile(),
          ProfileMenuTile(
            icon: Assets.icons.countryIcn,
            title: context.tr(LocaleKeys.country),
            trailing: _Caret(),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// The avatar/name/email header, fed by the app-wide [CurrentUserCubit]
/// (`GET /api/profile`). Shows skeleton bones until the first load lands, and
/// falls back to the placeholder name/email if the call fails so the row never
/// collapses.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentUserCubit, CurrentUserState>(
      builder: (context, state) {
        final user = state.profile;
        return Skeletonizer(
          enabled: state.isLoading,
          child: ProfileHeader(
            name: user?.name ?? 'Klik customer',
            email: user?.email ?? '',
            // An empty string would try (and fail) to load a network image.
            avatarUrl: (user?.profilePhoto ?? '').isEmpty
                ? null
                : user!.profilePhoto,
            onEdit: () => context.push(AppRoutes.editProfile),
          ),
        );
      },
    );
  }
}

/// Circular bronze support (headset) button in the app bar.
class _SupportButton extends StatelessWidget {
  const _SupportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: context.r(24),
      child: Assets.icons.supportIcn.svg(),
    );
  }
}

/// Trailing dropdown caret used by the Language / Country rows.
class _Caret extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.keyboard_arrow_down_rounded,
      size: context.r(24),
      color: AppColors.primary,
    );
  }
}
