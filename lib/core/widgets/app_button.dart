import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The design uses four button shapes. Rather than expose raw height/radius
/// at every call site, each one is a named variant so a screen can't
/// accidentally invent a fifth.
enum AppButtonVariant {
  /// 56h, r8, gold — Login, Register, Update Profile, Submit Order.
  primary,

  /// 56h, r8, dark — "Add To Cart" on Book Details.
  dark,

  /// 56h, r8, white with a dark border — secondary actions.
  outlined,

  /// 55h, r4, gold — the Cart screen's Checkout bar.
  checkout,

  /// 28h, r4, dark — the small "Buy" pill on a book card.
  pill,
}

extension on AppButtonVariant {
  double get height => switch (this) {
    AppButtonVariant.checkout => 55,
    AppButtonVariant.pill => 28,
    _ => 56,
  };

  double get radius => switch (this) {
    AppButtonVariant.checkout || AppButtonVariant.pill => AppRadius.pill,
    _ => AppRadius.input,
  };

  Color get background => switch (this) {
    AppButtonVariant.primary || AppButtonVariant.checkout => AppColors.primary,
    AppButtonVariant.dark || AppButtonVariant.pill => AppColors.dark,
    AppButtonVariant.outlined => AppColors.white,
  };

  Color get foreground => switch (this) {
    AppButtonVariant.outlined => AppColors.dark,
    _ => AppColors.white,
  };

  Color? get borderColor =>
      this == AppButtonVariant.outlined ? AppColors.dark : null;

  TextStyle get textStyle => switch (this) {
    AppButtonVariant.pill => AppTextStyle.caption,
    AppButtonVariant.checkout => AppTextStyle.title,
    _ => AppTextStyle.title,
  };
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.isEnabled = true,
    this.icon,
  });

  final String label;

  /// A null [onTap] — or `isEnabled: false` — renders the disabled state and
  /// swallows taps, which is how screens block a second submit while a
  /// request is in flight.
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final double? width;
  final bool isEnabled;
  final Widget? icon;

  bool get _isInteractive => isEnabled && onTap != null;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(variant.radius.r);

    return Opacity(
      opacity: _isInteractive ? 1 : 0.5,
      child: Material(
        color: variant.background,
        borderRadius: radius,
        child: InkWell(
          onTap: _isInteractive ? onTap : null,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: width?.w ?? double.infinity,
            height: variant.height.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: variant.borderColor == null
                  ? null
                  : Border.all(color: variant.borderColor!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: variant.textStyle.copyWith(
                      color: variant.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
