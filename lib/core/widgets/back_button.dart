import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The 41x41, r12 white back button that appears at (24, 55) on every
/// secondary screen.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap});

  /// Defaults to popping the current route.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.backButton.r);
    // The arrow points back, which is rightwards under an RTL locale.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        borderRadius: radius,
        child: Container(
          width: 41.w,
          height: 41.h,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Transform.flip(
              flipX: isRtl,
              child: SvgPicture.asset(
                Assets.icons.backArrow,
                width: 19.w,
                height: 19.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.dark,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
