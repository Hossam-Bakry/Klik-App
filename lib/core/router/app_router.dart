import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/presentation/bloc/auth_bloc.dart';
import '../../modules/auth/presentation/cubit/password_reset_cubit.dart';
import '../../modules/auth/presentation/pages/change_password_page.dart';
import '../../modules/auth/presentation/pages/forgot_password_page.dart';
import '../../modules/auth/presentation/pages/login_page.dart';
import '../../modules/auth/presentation/pages/otp_verification_page.dart';
import '../../modules/auth/presentation/pages/register_page.dart';
import '../../modules/main/presentation/pages/main_layout_page.dart';
import '../../modules/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../modules/onboarding/presentation/pages/onboarding_page.dart';
import '../../modules/splash/presentation/pages/splash_view.dart';
import '../di/injector.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

/// App-wide navigation with a two-stage guard driven by [OnboardingCubit] and
/// [AuthBloc]. Precedence on each navigation:
///   1. still bootstrapping (either state unknown) → splash
///   2. authenticated → straight into the app (skip onboarding/auth)
///   3. onboarding required → onboarding
///   4. unauthenticated → confined to the auth flow (login/register/forgot/otp)
class AppRouter {
  const AppRouter._();

  static GoRouter create(AuthBloc authBloc, OnboardingCubit onboardingCubit) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      // Re-run [redirect] when either piece of gate state changes.
      refreshListenable: Listenable.merge([
        GoRouterRefreshStream(authBloc.stream),
        GoRouterRefreshStream(onboardingCubit.stream),
      ]),
      redirect: (context, state) {
        final auth = authBloc.state.status;
        final onboarding = onboardingCubit.state.status;
        final location = state.matchedLocation;

        // 1. Bootstrapping — wait on splash until both states resolve.
        if (auth == AuthStatus.unknown || onboarding == OnboardingStatus.unknown) {
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        }

        // 2. Authenticated — push past any pre-app screen.
        if (auth == AuthStatus.authenticated) {
          if (location == AppRoutes.splash ||
              location == AppRoutes.onboarding ||
              AppRoutes.authFlow.contains(location)) {
            return AppRoutes.home;
          }
          return null;
        }

        // 3. First launch — show onboarding before the auth flow.
        if (onboarding == OnboardingStatus.required) {
          return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        }

        // 4. Onboarded but unauthenticated — confine to the auth flow.
        if (!AppRoutes.authFlow.contains(location)) {
          return AppRoutes.login;
        }
        return null;
      },
      routes: [
        GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashView()),
        GoRoute(path: AppRoutes.onboarding, builder: (context, state) => const OnboardingPage()),
        GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginPage()),
        GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterPage()),
        GoRoute(
          path: AppRoutes.forgotPassword,
          // Page-scoped cubit provided at the route; handed to the OTP route
          // via `extra` so the same instance carries the flow's state.
          builder: (context, state) =>
              BlocProvider(create: (_) => sl<PasswordResetCubit>(), child: const ForgotPasswordPage()),
        ),
        GoRoute(
          path: AppRoutes.otp,
          // The OTP screen needs the in-flight cubit handed over via `extra`.
          // If reached without it (e.g. deep link), bounce to forgot-password.
          redirect: (context, state) => state.extra is PasswordResetCubit ? null : AppRoutes.forgotPassword,
          builder: (context, state) => OtpVerificationPage(cubit: state.extra as PasswordResetCubit),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          // Same in-flight cubit handed over via `extra` (now holding the reset
          // token from verify-otp). Bounce to forgot-password if missing.
          redirect: (context, state) => state.extra is PasswordResetCubit ? null : AppRoutes.forgotPassword,
          builder: (context, state) => ChangePasswordPage(cubit: state.extra as PasswordResetCubit),
        ),
        GoRoute(
          // Post-login shell hosting the bottom-nav destinations (Home tab
          // provides its own CatalogBloc internally).
          path: AppRoutes.home,
          builder: (context, state) => const MainLayoutPage(),
        ),
      ],
    );
  }
}
