import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The centred screen title used by Wishlist, My Cart, Profile, Edit Profile
/// and Order History.
///
/// The title stays optically centred whether or not there is a back button or
/// a trailing action, by reserving the same 41px on both sides.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.showBack = false,
    this.trailing,
    this.onBack,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    const double slotWidth = 41;

    return SizedBox(
      height: slotWidth.h,
      child: Row(
        children: [
          SizedBox(
            width: slotWidth.w,
            child: showBack
                ? AppBackButton(onTap: onBack)
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.headline,
            ),
          ),
          SizedBox(
            width: slotWidth.w,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: trailing ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A 24x24 tappable icon for a header's trailing slot (logout, bookmark).
class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.child,
    required this.onTap,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkResponse(
      onTap: onTap,
      radius: 24.r,
      child: Padding(padding: EdgeInsets.all(4.r), child: child),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Shown when a list comes back empty. Keeps the four empty states
/// (cart, wishlist, orders, search) visually identical.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40.sp, color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            Text(title, textAlign: TextAlign.center, style: AppTextStyle.title),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.body.copyWith(color: AppColors.secondaryText),
            ),
            if (action != null) ...[SizedBox(height: 24.h), action!],
          ],
        ),
      ),
    );
  }
}
