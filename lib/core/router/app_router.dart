import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../modules/address/domain/entities/address.dart';
import '../../modules/address/presentation/bloc/address_bloc.dart';
import '../../modules/address/presentation/pages/add_edit_address_page.dart';
import '../../modules/address/presentation/pages/address_list_page.dart';
import '../../modules/auth/presentation/bloc/auth_bloc.dart';
import '../../modules/auth/presentation/cubit/password_reset_cubit.dart';
import '../../modules/auth/presentation/pages/change_password_page.dart';
import '../../modules/auth/presentation/pages/forgot_password_page.dart';
import '../../modules/auth/presentation/pages/login_page.dart';
import '../../modules/auth/presentation/pages/otp_verification_page.dart';
import '../../modules/auth/presentation/pages/phone_verification_page.dart';
import '../../modules/auth/presentation/pages/register_page.dart';
import '../../modules/main/presentation/pages/main_layout_page.dart';
import '../../modules/onboarding/presentation/cubit/onboarding_cubit.dart';
import '../../modules/onboarding/presentation/pages/onboarding_page.dart';
import '../../modules/product/presentation/bloc/product_bloc.dart';
import '../../modules/product/presentation/pages/product_details_page.dart';
import '../../modules/products/domain/entities/products_filter.dart';
import '../../modules/products/presentation/bloc/products_bloc.dart';
import '../../modules/products/presentation/pages/products_list_page.dart';
import '../../modules/profile/presentation/cubit/edit_profile_cubit.dart';
import '../../modules/profile/presentation/pages/edit_profile_page.dart';
import '../../modules/security/presentation/cubit/security_cubit.dart';
import '../../modules/security/presentation/pages/security_page.dart';
import '../../modules/shops/presentation/bloc/shops_bloc.dart';
import '../../modules/shops/presentation/pages/shops_page.dart';
import '../../modules/splash/presentation/pages/splash_view.dart';
import '../../modules/support/presentation/cubit/support_cubit.dart';
import '../../modules/support/presentation/pages/support_page.dart';
import '../../modules/update_password/presentation/cubit/update_password_cubit.dart';
import '../../modules/update_password/presentation/pages/update_password_page.dart';
import '../../modules/wishlist/presentation/bloc/wishlist_bloc.dart';
import '../../modules/wishlist/presentation/pages/wishlist_page.dart';
import '../di/injector.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';

/// App-wide navigation with a guard driven by [OnboardingCubit] and [AuthBloc].
/// Precedence on each navigation:
///   1. still bootstrapping (either state unknown) → splash
///   2. onboarding required → onboarding
///   3. authenticated → bounced out of splash/onboarding/auth screens into app
///   4. guest (unauthenticated) → may browse the app and visit the auth flow,
///      but auth-required routes ([AppRoutes.authRequired]) redirect to login
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
        if (auth == AuthStatus.unknown ||
            onboarding == OnboardingStatus.unknown) {
          return location == AppRoutes.splash ? null : AppRoutes.splash;
        }

        // 2. First launch — show onboarding before anything else.
        if (onboarding == OnboardingStatus.required) {
          return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
        }

        // 3. Authenticated — push past any pre-app/auth screen into the app.
        if (auth == AuthStatus.authenticated) {
          if (location == AppRoutes.splash ||
              location == AppRoutes.onboarding ||
              AppRoutes.authFlow.contains(location)) {
            return AppRoutes.home;
          }
          return null;
        }

        // 4. Guest (unauthenticated) — free to browse the app and to enter the
        // auth flow. Leaving a pre-app screen lands on home; account-only
        // routes bounce to login.
        if (location == AppRoutes.splash || location == AppRoutes.onboarding) {
          return AppRoutes.home;
        }
        if (AppRoutes.authRequired.contains(location)) {
          return AppRoutes.login;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          // Page-scoped cubit provided at the route; handed to the OTP route
          // via `extra` so the same instance carries the flow's state.
          builder: (context, state) => BlocProvider(
            create: (_) => sl<PasswordResetCubit>(),
            child: const ForgotPasswordPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.otp,
          // The OTP screen needs the in-flight cubit handed over via `extra`.
          // If reached without it (e.g. deep link), bounce to forgot-password.
          redirect: (context, state) => state.extra is PasswordResetCubit
              ? null
              : AppRoutes.forgotPassword,
          builder: (context, state) =>
              OtpVerificationPage(cubit: state.extra as PasswordResetCubit),
        ),
        GoRoute(
          path: AppRoutes.verifyPhone,
          // Post-registration phone activation. Reads the pending phone from the
          // app-level AuthBloc; if reached without one (e.g. deep link), bounce
          // to register.
          redirect: (context, state) =>
              sl<AuthBloc>().state.pendingVerification == null &&
                  !sl<AuthBloc>().state.isAuthenticated
              ? AppRoutes.register
              : null,
          builder: (context, state) => const PhoneVerificationPage(),
        ),
        GoRoute(
          path: AppRoutes.changePassword,
          // Same in-flight cubit handed over via `extra` (now holding the reset
          // token from verify-otp). Bounce to forgot-password if missing.
          redirect: (context, state) => state.extra is PasswordResetCubit
              ? null
              : AppRoutes.forgotPassword,
          builder: (context, state) =>
              ChangePasswordPage(cubit: state.extra as PasswordResetCubit),
        ),
        GoRoute(
          // Post-login shell hosting the bottom-nav destinations (Home tab
          // provides its own CatalogBloc internally).
          path: AppRoutes.home,
          builder: (context, state) => const MainLayoutPage(),
        ),
        // Product details (public — guests may browse). The product id arrives
        // via `extra`; a fresh page-scoped ProductBloc loads it. Reached without
        // an id (e.g. deep link) bounces home.
        GoRoute(
          path: AppRoutes.productDetails,
          redirect: (context, state) =>
              state.extra is int ? null : AppRoutes.home,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<ProductBloc>()
              ..add(ProductDetailsRequested(state.extra as int)),
            child: const ProductDetailsPage(),
          ),
        ),
        // Unified products list (public). The entry point's ProductsFilter
        // arrives via `extra`; a fresh page-scoped ProductsBloc loads page 1.
        // Reached without a filter (e.g. deep link) falls back to an unfiltered
        // list rather than bouncing.
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) {
            final filter = state.extra is ProductsFilter
                ? state.extra as ProductsFilter
                : const ProductsFilter();
            // `?focus=true` (set by the home search field) opens the page as a
            // search screen: it autofocuses the input so the keyboard rises
            // straight away, and stays idle (empty list) until the user types.
            final searchMode = state.uri.queryParameters['focus'] == 'true';
            return BlocProvider(
              create: (_) => sl<ProductsBloc>()
                ..add(ProductsStarted(filter, searchMode: searchMode)),
              child: ProductsListPage(autofocusSearch: searchMode),
            );
          },
        ),
        // Wishlist (auth-required — favorites are per-user). Page-scoped
        // WishlistBloc loads the favorite products.
        GoRoute(
          path: AppRoutes.wishlist,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<WishlistBloc>()..add(const WishlistStarted()),
            child: const WishlistPage(),
          ),
        ),
        // Shops list (public — guests may browse). Page-scoped ShopsBloc reads
        // the shared AddressBloc to decide whether to send location params.
        GoRoute(
          path: AppRoutes.shops,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<ShopsBloc>()..add(const ShopsStarted()),
            child: const ShopsPage(),
          ),
        ),
        // Support form (public — no session required). Page-scoped
        // SupportCubit owns the single submit action.
        GoRoute(
          path: AppRoutes.support,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SupportCubit>(),
            child: const SupportPage(),
          ),
        ),
        // Security (auth-required — account deletion). Page-scoped
        // SecurityCubit owns the single delete-account action.
        GoRoute(
          path: AppRoutes.security,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SecurityCubit>(),
            child: const SecurityPage(),
          ),
        ),
        // Change password (auth-required — account settings). Distinct from
        // AppRoutes.changePassword, the forgot-password flow's OTP-token step.
        // Page-scoped UpdatePasswordCubit owns the single submit action.
        GoRoute(
          path: AppRoutes.updatePassword,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<UpdatePasswordCubit>(),
            child: const UpdatePasswordPage(),
          ),
        ),
        // Edit Profile (auth-required). Page-scoped EditProfileCubit fetches
        // the current profile on creation, then submits edits.
        GoRoute(
          path: AppRoutes.editProfile,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<EditProfileCubit>(),
            child: const EditProfilePage(),
          ),
        ),
        // Address list/add/edit share the singleton AddressBloc so mutations
        // update the list/selection that the home header and bottom sheet read.
        // Edit receives the Address via `extra`.
        GoRoute(
          path: AppRoutes.addressList,
          builder: (context, state) => BlocProvider.value(
            value: sl<AddressBloc>(),
            child: const AddressListPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.addressAdd,
          builder: (context, state) => BlocProvider.value(
            value: sl<AddressBloc>(),
            child: const AddEditAddressPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.addressEdit,
          builder: (context, state) => BlocProvider.value(
            value: sl<AddressBloc>(),
            child: AddEditAddressPage(address: state.extra as Address?),
          ),
        ),
      ],
    );
  }
}
