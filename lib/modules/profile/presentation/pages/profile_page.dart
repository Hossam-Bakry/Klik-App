import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';
import '../widgets/language_selector_tile.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_footer.dart';
import '../widgets/profile_guest_header.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_quick_actions.dart';
import '../widgets/profile_section_card.dart';

/// Profile destination (tab index 4): the account hub with quick shortcuts,
/// settings, support links, and sign-out.
///
/// Adapts to [AuthStatus]: a guest sees a sign-in header and account-only rows
/// route through [AuthGuard.requireAuth] (which prompts sign-in). A signed-in
/// user sees their details and the logout action.
///
/// Name/email/avatar are placeholders for now — [AuthSession] only carries a
/// token; wire these to a user profile once the backend exposes one.
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
            child: _SupportButton(onTap: () {}),
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
                if (isGuest)
                  const ProfileGuestHeader()
                else
                  const ProfileHeader(
                    name: 'Sarah Ahmed',
                    email: 'sarahahmed@gmail.com',
                  ),
                context.gapH(20),

                // Quick shortcuts.
                ProfileSectionCard(
                  padding: context.edgeSymmetric(horizontal: 12, vertical: 16),
                  child: ProfileQuickActions(
                    onOrders: () => gated(() {}),
                    onNegotiation: () => gated(() {}),
                    onWishlist: () => gated(() {}),
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
                ProfileSectionCard(
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
                ),
                context.gapH(16),

                // Account & legal.
                ProfileSectionCard(
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Assets.icons.changePasswordIcn,
                        title: context.tr(LocaleKeys.changePassword),
                        trailing: const ProfileTileChevron(),
                        onTap: () => gated(() {}),
                      ),
                      ProfileMenuTile(
                        icon: Assets.icons.securityIcn,
                        title: context.tr(LocaleKeys.security),
                        trailing: const ProfileTileChevron(),
                        onTap: () => gated(() {}),
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
                      // Logout is only meaningful for a signed-in user; guests
                      // sign in from the header CTA instead.
                      if (!isGuest)
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
                            }
                          },
                        ),
                    ],
                  ),
                ),
                context.gapH(16),

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
      child: Container(
        padding: context.edgeAll(9),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.headset_mic_outlined,
          size: context.r(20),
          color: AppColors.surface,
        ),
      ),
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
