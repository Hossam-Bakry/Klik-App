import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../../core/cart/presentation/cart_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/auth_prompt.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../categories/presentation/bloc/categories_bloc.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../home/domain/entities/category_item.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../home/presentation/pages/open_to_offers_page.dart';
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
  /// prompt instead of switching. Cart (3) is deliberately absent — a guest
  /// builds a cart on the device and only signs in at checkout.
  static const Set<int> _authRequiredTabs = {2};

  // Singleton: shared with the home header, bottom sheet, and add/edit routes.
  // For a signed-in user we load saved addresses; a guest only gets the GPS
  // "Deliver to" label (no account, so no saved-address fetch / 401).
  final AddressBloc _addressBloc = sl<AddressBloc>()
    ..add(sl<AuthBloc>().state.isAuthenticated
        ? const AddressStarted()
        : const CurrentLocationRequested());

  // Singleton: lifted out of `pages` (rather than created inline) so the home
  // tab's category-tap handler can dispatch into the same instance the
  // Categories tab renders.
  final CategoriesBloc _categoriesBloc = sl<CategoriesBloc>()
    ..add(const CategoriesStarted());

  void _onTabTapped(int i) {
    if (_authRequiredTabs.contains(i) && !context.isAuthenticated) {
      showAuthRequiredSheet(context);
      return;
    }
    setState(() => _index = i);
  }

  /// Tapped a category thumbnail on Home: select it on the Categories tab —
  /// same as tapping it there directly — then switch to that tab.
  void _openCategory(CategoryItem category) {
    _categoriesBloc.add(CategoryTappedById(category.id));
    _onTabTapped(1);
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
          onCategoryTap: _openCategory,
        ),
      ),
      BlocProvider.value(
        value: _categoriesBloc,
        child: const CategoriesPage(),
      ),
      // Negotiation destination: the full bidable listing (is_bidable=1), with
      // its own search + filter. Where Home's "Open to offers" see-all lands.
      const OpenToOffersPage(),
      // Cart — open to guests; their lines live on the device until sign-in
      // merges them into the account.
      CartPage(onBack: () => _onTabTapped(0)),
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
          bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
            buildWhen: (p, c) => p.itemCount != c.itemCount,
            builder: (context, cart) => CurvedBottomNav(
              currentIndex: _index,
              onTap: _onTabTapped,
              cartCount: cart.itemCount,
            ),
          ),
        ),
      ),
    );
  }
}
