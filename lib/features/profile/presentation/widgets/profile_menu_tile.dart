import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The 335x54, r6 row used six times on the Profile screen.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.tile.r);
    final foreground = isDestructive ? AppColors.danger : AppColors.label;
    // The chevron points forward, which flips under an RTL locale.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 54.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.subtitle.copyWith(color: foreground),
                ),
              ),
              Transform.flip(
                flipX: isRtl,
                child: SvgPicture.asset(
                  Assets.icons.chevronRight,
                  width: 7.w,
                  height: 13.h,
                  colorFilter: ColorFilter.mode(
                    isDestructive ? AppColors.danger : AppColors.dark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
