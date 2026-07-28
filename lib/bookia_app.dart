import 'package:bookia_app/core/routing/app_router.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/core/theme/app_theme.dart';
import 'package:bookia_app/core/utils/app_keys.dart';
import 'package:bookia_app/core/widgets/global_feedback.dart';
import 'package:bookia_app/di/service_locator.dart';
import 'package:bookia_app/features/cart/cubit/cart_cubit.dart';
import 'package:bookia_app/features/cart/data/cart_repo.dart';
import 'package:bookia_app/features/profile/cubit/profile_cubit.dart';
import 'package:bookia_app/features/profile/data/profile_repo.dart';
import 'package:bookia_app/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:bookia_app/features/wishlist/data/wishlist_repo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

class BookiaApp extends StatelessWidget {
  const BookiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // The Figma canvas. Every `.w`/`.h`/`.sp` in the app scales from this.
      designSize: const Size(375, 812),
      splitScreenMode: true,
      minTextAdapt: true,
      child: MultiBlocProvider(
        // Cart, wishlist and profile are app-wide: the nav badge, the
        // bookmark on Book Details and the Profile tab all read the same
        // instances, so they can never disagree.
        providers: [
          BlocProvider(
            create: (_) => CartCubit(
              repo: getIt<CartRepository>(),
              storage: getIt<SessionStorage>(),
            ),
          ),
          BlocProvider(
            create: (_) => WishlistCubit(
              repo: getIt<WishlistRepository>(),
              storage: getIt<SessionStorage>(),
            ),
          ),
          BlocProvider(create: (_) => ProfileCubit(getIt<ProfileRepository>())),
        ],
        child: ToastificationWrapper(
          // One listener for cart/wishlist outcomes, above the navigator, so
          // an action taken from Book Details cannot also be reported by the
          // Cart tab still mounted beneath it.
          child: GlobalFeedback(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: AppKeys.navigator,
              theme: AppTheme.light,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: Routes.splashScreen,
              builder: (context, child) => MediaQuery.withClampedTextScaling(
                // Keeps the fixed-height design (56px buttons, 54px rows)
                // legible without letting an extreme system text size break
                // every layout.
                minScaleFactor: 0.8,
                maxScaleFactor: 1.3,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
