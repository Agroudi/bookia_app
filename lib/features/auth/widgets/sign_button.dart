import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The 329x56 white social sign-in button from the Login screen.
class SignButton extends StatelessWidget {
  const SignButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.input.r);

    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 56.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(iconAsset, width: 26.w, height: 26.h),
              SizedBox(width: 10.w),
              Text(
                label,
                style: AppTextStyle.caption.copyWith(
                  color: AppColors.iconMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
