import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/di/service_locator.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// Decides where the app opens.
///
///   * never onboarded  -> onboarding
///   * onboarded, no token -> login
///   * has a token      -> straight into the shell
///
/// The token is not verified here: any request the shell makes will 401 if it
/// has expired, and the auth interceptor routes back to login. Blocking the
/// splash on a validation call would just add a round trip to every cold
/// start.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Long enough for the loader animation to read as intentional rather than
  /// a flash of the wrong screen.
  static const Duration _minimumDwell = Duration(milliseconds: 1400);

  @override
  void initState() {
    super.initState();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    final storage = getIt<SessionStorage>();
    await Future<void>.delayed(_minimumDwell);
    if (!mounted) return;

    final next = switch ((storage.hasSeenOnboarding, storage.isLoggedIn)) {
      (false, _) => Routes.boardingScreen,
      (true, false) => Routes.loginScreen,
      (true, true) => Routes.layoutScreen,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(next, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              Assets.animations.bookLoader,
              width: 200.w,
              height: 200.w,
              errorBuilder: (_, _, _) => Assets.icons.logo.image(width: 160.w),
            ),
            SizedBox(height: 16.h),
            Assets.icons.logo.image(width: 150.w),
          ],
        ),
      ),
    );
  }
}
