import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The four tabs, in the order the design lays them out.
///
/// The third tab's Figma layer is misnamed "Category" but draws a shopping
/// cart, which is what it is.
enum AppTab { home, wishlist, cart, profile }

extension AppTabAsset on AppTab {
  String get icon => switch (this) {
    AppTab.home => Assets.icons.home,
    AppTab.wishlist => Assets.icons.bookmark,
    AppTab.cart => Assets.icons.cart,
    AppTab.profile => Assets.icons.profile,
  };

  String get label => switch (this) {
    AppTab.home => LocaleKeys.nav_home,
    AppTab.wishlist => LocaleKeys.nav_wishlist,
    AppTab.cart => LocaleKeys.nav_cart,
    AppTab.profile => LocaleKeys.nav_profile,
  };

  /// Icon box sizes are per-tab in the design (21x22, 18x20, 20x19, 16x20);
  /// they are normalised to a 24px box here so the row stays even.
  Size get size => switch (this) {
    AppTab.home => const Size(22, 23),
    AppTab.wishlist => const Size(19, 21),
    AppTab.cart => const Size(22, 21),
    AppTab.profile => const Size(18, 22),
  };
}

/// The floating 327x65 navigation card.
///
/// The Figma file draws two variants — full-width on Home, floating on every
/// other tab — with no active state on Home at all. The floating one is used
/// throughout: it is the majority, and it is the only variant that shows which
/// tab you are on.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onSelected,
    this.cartCount = 0,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelected;

  /// Drawn as a badge on the cart tab; hidden when zero.
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenWide.w,
          0,
          AppSpacing.screenWide.w,
          12.h,
        ),
        child: Container(
          height: 65.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final tab in AppTab.values)
                _NavItem(
                  tab: tab,
                  isActive: tab == current,
                  badgeCount: tab == AppTab.cart ? cartCount : 0,
                  onTap: () => onSelected(tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.badgeCount,
  });

  final AppTab tab;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.dark;

    return Semantics(
      label: tab.label.tr(),
      selected: isActive,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32.r,
        child: SizedBox(
          width: 56.w,
          height: 65.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The active tab lifts slightly and grows; the gold alone is a
              // weak signal at this icon size.
              AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset: Offset(0, isActive ? -0.06 : 0),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  scale: isActive ? 1.12 : 1,
                  child: SvgPicture.asset(
                    tab.icon,
                    width: tab.size.width.w,
                    height: tab.size.height.h,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
              ),
              if (badgeCount > 0)
                PositionedDirectional(
                  top: 14.h,
                  end: 10.w,
                  child: _Badge(count: badgeCount),
                ),
              PositionedDirectional(
                bottom: 12.h,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: isActive ? 18.w : 0,
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3.r),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.white, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9.sp,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
    );
  }
}
