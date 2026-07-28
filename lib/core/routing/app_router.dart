import 'package:bookia_app/core/routing/app_page_route.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/widgets/locale_scope.dart';
import 'package:bookia_app/di/service_locator.dart';
import 'package:bookia_app/features/auth/cubit/auth_cubit.dart';
import 'package:bookia_app/features/auth/data/repo/auth_repo.dart';
import 'package:bookia_app/features/auth/presentaion/create_new_pass_screen.dart';
import 'package:bookia_app/features/auth/presentaion/forgot_password_screen.dart';
import 'package:bookia_app/features/auth/presentaion/login_screen.dart';
import 'package:bookia_app/features/auth/presentaion/otp_verification_screen.dart';
import 'package:bookia_app/features/auth/presentaion/register_screen.dart';
import 'package:bookia_app/features/boarding/presentation/boarding_screen.dart';
import 'package:bookia_app/features/book_details/cubit/book_details_cubit.dart';
import 'package:bookia_app/features/book_details/presentation/book_details_screen.dart';
import 'package:bookia_app/features/home/cubit/home_cubit.dart';
import 'package:bookia_app/features/home/data/repo/catalog_repo.dart';
import 'package:bookia_app/features/layout/presentation/layout_screen.dart';
import 'package:bookia_app/features/orders/cubit/orders_cubit.dart';
import 'package:bookia_app/features/orders/data/orders_repo.dart';
import 'package:bookia_app/features/orders/presentation/order_details_screen.dart';
import 'package:bookia_app/features/orders/presentation/order_history_screen.dart';
import 'package:bookia_app/features/orders/presentation/place_order_screen.dart';
import 'package:bookia_app/features/profile/data/profile_repo.dart';
import 'package:bookia_app/features/profile/presentation/contact_us_screen.dart';
import 'package:bookia_app/features/profile/presentation/edit_profile_screen.dart';
import 'package:bookia_app/features/profile/presentation/faq_screen.dart';
import 'package:bookia_app/features/profile/presentation/update_password_screen.dart';
import 'package:bookia_app/features/search/cubit/search_cubit.dart';
import 'package:bookia_app/features/search/presentation/search_screen.dart';
import 'package:bookia_app/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Builds every route, providing each screen with exactly the cubits it needs.
///
/// Screen-scoped cubits (auth, search, book details, orders) are created here
/// so they are disposed with the route. The app-wide ones (cart, wishlist,
/// profile) live above the navigator in `BookiaApp`.
abstract final class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return AppPageRoute.fade(
          _page(() => SplashScreen()),
          settings: settings,
        );

      case Routes.boardingScreen:
        return AppPageRoute.fade(
          _page(() => BoardingScreen()),
          settings: settings,
        );

      case Routes.loginScreen:
        return AppPageRoute.fade(
          _withAuth(_page(() => LoginScreen())),
          settings: settings,
        );

      case Routes.registerScreen:
        return AppPageRoute.slide(
          _withAuth(_page(() => RegisterScreen())),
          settings: settings,
        );

      case Routes.forgetPasswordScreen:
        return AppPageRoute.slide(
          _withAuth(_page(() => ForgotPasswordScreen())),
          settings: settings,
        );

      case Routes.otpScreen:
        final args = settings.arguments;
        if (args is! OtpArgs) return _invalidArgs(settings);
        return AppPageRoute.slide(
          _withAuth(_page(() => OtpVerificationScreen(args: args))),
          settings: settings,
        );

      case Routes.createNewPasswordScreen:
        final args = settings.arguments;
        if (args is! ResetPasswordArgs) return _invalidArgs(settings);
        return AppPageRoute.slide(
          _withAuth(_page(() => CreateNewPassScreen(args: args))),
          settings: settings,
        );

      case Routes.layoutScreen:
        return AppPageRoute.fade(
          MultiBlocProvider(
            providers: [
              // Logout lives on the Profile tab, so the shell needs AuthCubit.
              BlocProvider(create: (_) => AuthCubit(getIt<AuthRepository>())),
              // Scoped to the shell rather than the app: the home sections are
              // only ever shown here, and this disposes them with the shell on
              // sign-out.
              BlocProvider(
                create: (_) => HomeCubit(getIt<CatalogRepository>()),
              ),
            ],
            child: _page(() => LayoutScreen()),
          ),
          settings: settings,
        );

      case Routes.searchScreen:
        return AppPageRoute.rise(
          BlocProvider(
            create: (_) => SearchCubit(getIt<CatalogRepository>()),
            child: _page(() => SearchScreen()),
          ),
          settings: settings,
        );

      case Routes.bookDetailsScreen:
        final args = settings.arguments;
        if (args is! BookDetailsArgs) return _invalidArgs(settings);
        return AppPageRoute.rise(
          BlocProvider(
            create: (_) => BookDetailsCubit(getIt<CatalogRepository>()),
            child: _page(() => BookDetailsScreen(args: args)),
          ),
          settings: settings,
        );

      case Routes.editProfileScreen:
        return AppPageRoute.slide(
          _page(() => EditProfileScreen()),
          settings: settings,
        );

      case Routes.updatePasswordScreen:
        return AppPageRoute.slide(
          _page(() => UpdatePasswordScreen()),
          settings: settings,
        );

      case Routes.faqScreen:
        return AppPageRoute.slide(
          _page(() => FaqScreen(repo: getIt<ProfileRepository>())),
          settings: settings,
        );

      case Routes.contactUsScreen:
        return AppPageRoute.slide(
          _page(() => ContactUsScreen()),
          settings: settings,
        );

      case Routes.orderHistoryScreen:
        return AppPageRoute.slide(
          _withOrders(_page(() => OrderHistoryScreen())),
          settings: settings,
        );

      case Routes.orderDetailsScreen:
        final orderId = settings.arguments;
        if (orderId is! int) return _invalidArgs(settings);
        return AppPageRoute.rise(
          _withOrders(_page(() => OrderDetailsScreen(orderId: orderId))),
          settings: settings,
        );

      case Routes.placeOrderScreen:
        return AppPageRoute.rise(
          _withOrders(_page(() => PlaceOrderScreen())),
          settings: settings,
        );

      default:
        return AppPageRoute.fade(
          _page(() => SplashScreen()),
          settings: settings,
        );
    }
  }

  /// Wraps a page so its translated strings refresh when the locale changes.
  static Widget _page(Widget Function() builder) =>
      LocaleScope(builder: builder);

  static Widget _withAuth(Widget child) => BlocProvider(
    create: (_) => AuthCubit(getIt<AuthRepository>()),
    child: child,
  );

  static Widget _withOrders(Widget child) => BlocProvider(
    create: (_) => OrdersCubit(getIt<OrdersRepository>()),
    child: child,
  );

  /// A route reached without the arguments it requires is a programming
  /// error; failing to the splash gate is preferable to a null crash in
  /// release.
  static Route<dynamic> _invalidArgs(RouteSettings settings) =>
      AppPageRoute.fade(_page(() => SplashScreen()), settings: settings);
}
