import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/curved_bottom_nav.dart';

/// Post-login shell: keeps all five destinations alive in an [IndexedStack] and
/// swaps between them via the [CurvedBottomNav]. Index 2 is the centre circle.
class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _index = 0;

  /// Tabs that need a real session. A guest tapping these gets the sign-in
  /// prompt instead of switching (negotiation = 2, cart = 3).
  static const Set<int> _authRequiredTabs = {2, 3};

  // Singleton: shared with the home header, bottom sheet, and add/edit routes.
  // For a signed-in user we load saved addresses; a guest only gets the GPS
  // "Deliver to" label (no account, so no saved-address fetch / 401).
  final AddressBloc _addressBloc = sl<AddressBloc>()
    ..add(sl<AuthBloc>().state.isAuthenticated
        ? const AddressStarted()
        : const CurrentLocationRequested());

  void _onTabTapped(int i) {
    if (_authRequiredTabs.contains(i) && !context.isAuthenticated) {
      showAuthRequiredSheet(context);
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Home — its sections consume this page-scoped HomeBloc.
      BlocProvider(
        create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
        // "See all" jumps to the matching tab (gated for guests via
        // _onTabTapped, same as tapping the tab directly).
        child: HomePage(
          onOpenCategories: () => _onTabTapped(1),
          onOpenOffers: () => _onTabTapped(2),
        ),
      ),
      _PlaceholderTab(icon: Assets.icons.categoryIcn),
      _PlaceholderTab(icon: Assets.icons.negotiationIcn),
      _PlaceholderTab(icon: Assets.icons.cartIcn),
      const ProfilePage(),
    ];

    // Provide the shared AddressBloc to the whole shell so the home header can
    // read the selected delivery address and open the chooser sheet.
    return BlocProvider.value(
      value: _addressBloc,
      // Keep address state in step with auth: load saved addresses on sign-in,
      // drop them (and the selection) on logout so a guest never sees the
      // previous user's delivery details.
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.isAuthenticated) {
            _addressBloc.add(const AddressStarted());
          } else if (state.isGuest) {
            _addressBloc.add(const AddressCleared());
          }
          // On any sign-in/sign-out transition, land on Home. The router pops
          // the auth route; this shared shell is reused, so reset its tab here.
          setState(() => _index = 0);
        },
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: CurvedBottomNav(
            currentIndex: _index,
            onTap: _onTabTapped,
          ),
        ),
      ),
    );
  }
}

/// Temporary content for destinations whose screens aren't built yet.
class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.icon});

  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon.svg(
              width: context.r(56),
              height: context.r(56),
              colorFilter: ColorFilter.mode(
                AppColors.primary.withValues(alpha: 0.4),
                BlendMode.srcIn,
              ),
            ),
            context.gapH(16),
            Text(
              context.tr(LocaleKeys.comingSoon),
              style: TextStyle(color: AppColors.textSecondary, fontSize: context.sp(15)),
            ),
          ],
        ),
      ),
    );
  }
}
