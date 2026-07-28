import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// The `book_loader` animation, used for *every* in-place loading state.
///
/// The app has one loading identity: this Lottie. Screens must not fall back
/// to a `CircularProgressIndicator` — a Material spinner on one screen and a
/// book animation on the next reads as two different apps.
///
/// [LoadingOverlay] is the full-screen, blocking variant of the same asset;
/// this widget is for the non-blocking cases where a region of a screen is
/// still filling in.
class AppLoader extends StatelessWidget {
  /// Fills an empty screen or an empty list.
  const AppLoader({super.key}) : size = 140;

  /// Sits inside a control — a "Buy" pill, a bookmark button — where the
  /// full-size animation would not fit.
  const AppLoader.inline({super.key}) : size = 30;

  /// Footer spinner while the next page of a list is appended.
  const AppLoader.pagination({super.key}) : size = 64;

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        Assets.animations.bookLoader,
        width: size.w,
        height: size.w,
        fit: BoxFit.contain,
        // The only place a Material spinner is legitimate: the Lottie itself
        // failed to decode, so showing nothing would look like a hang.
        errorBuilder: (_, _, _) => SizedBox(
          width: (size * 0.4).w,
          height: (size * 0.4).w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
