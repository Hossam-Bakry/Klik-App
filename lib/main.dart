import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/cart/presentation/cart_cubit.dart';
import 'core/di/injector.dart';
import 'core/favorites/presentation/favorites_cubit.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/localization/locale_keys.dart';
import 'core/network/connectivity_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/no_network_view.dart';
import 'modules/auth/presentation/bloc/auth_bloc.dart';
import 'modules/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'modules/profile/presentation/cubit/current_user_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Black status-bar text/icons app-wide (screens without an AppBar fall back
  // to this; AppBar screens get the same value from AppBarTheme).
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarStyle);
  await configureDependencies();
  runApp(const KlikApp());
}

class KlikApp extends StatefulWidget {
  const KlikApp({super.key});

  @override
  State<KlikApp> createState() => _KlikAppState();
}

class _KlikAppState extends State<KlikApp> {
  // App-level blocs that drive the router's redirect guard. Their states start
  // as `unknown`, so the guard holds on splash until they resolve.
  final AuthBloc _authBloc = sl<AuthBloc>();
  final OnboardingCubit _onboardingCubit = sl<OnboardingCubit>();
  final LocaleCubit _localeCubit = sl<LocaleCubit>();
  final ConnectivityCubit _connectivityCubit = sl<ConnectivityCubit>();
  final FavoritesCubit _favoritesCubit = sl<FavoritesCubit>();
  final CartCubit _cartCubit = sl<CartCubit>();
  final CurrentUserCubit _currentUserCubit = sl<CurrentUserCubit>();
  late final _router = AppRouter.create(_authBloc, _onboardingCubit);

  /// Minimum time the branded splash stays on screen before resolving where to
  /// go next. The startup reads (token / prefs) are local and instant, so
  /// deferring them by this delay gives a predictable splash duration.
  static const _splashMinDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    Future.delayed(_splashMinDuration, () {
      if (!mounted) return;
      _onboardingCubit.check();
      _authBloc.add(const AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _onboardingCubit),
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _connectivityCubit),
        BlocProvider.value(value: _favoritesCubit),
        BlocProvider.value(value: _cartCubit),
        BlocProvider.value(value: _currentUserCubit),
      ],
      // React to session transitions: on sign-in, merge any device-held guest
      // cart into the account and load the user's profile; on sign-out, drop
      // locally-known favorites, the profile and the account's cart so the next
      // session starts clean.
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          switch (state.status) {
            case AuthStatus.authenticated:
              _cartCubit.onSignedIn();
              _currentUserCubit.load();
            case AuthStatus.unauthenticated:
              _favoritesCubit.clear();
              _cartCubit.onSignedOut();
              _currentUserCubit.clear();
            case AuthStatus.unknown:
              break;
          }
        },
        // Rebuild MaterialApp when the locale changes; Flutter handles RTL for ar.
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).translate(LocaleKeys.appName),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(context),
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router,
              // Global connectivity overlay: the routed app stays mounted (so its
              // state survives), and the no-network view is laid over it while
              // offline — removed automatically once the connection returns.
              builder: (context, child) {
                return BlocBuilder<ConnectivityCubit, NetworkStatus>(
                  builder: (context, status) {
                    return Stack(
                      children: [
                        ?child,
                        if (status == NetworkStatus.offline)
                          const Positioned.fill(child: NoNetworkView()),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
