import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klik_app/gen/assets.gen.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/localization/locale_keys.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Home — its sections consume this page-scoped HomeBloc.
      BlocProvider(
        create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
        child: const HomePage(),
      ),
      _PlaceholderTab(icon: Assets.icons.categoryIcn),
      _PlaceholderTab(icon: Assets.icons.negotiationIcn),
      _PlaceholderTab(icon: Assets.icons.cartIcn),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: CurvedBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
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
