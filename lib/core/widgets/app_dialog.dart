import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Confirmation dialogs, styled to the design rather than to Material.
abstract final class AppDialog {
  /// Returns true only when the user picks the confirming action.
  ///
  /// [isDestructive] paints the confirm button red — used for logout, cart
  /// removal and account deletion so an irreversible action never looks like
  /// the safe default.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.dark.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, _, _) => _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel ?? LocaleKeys.confirm.tr(),
        cancelLabel: cancelLabel ?? LocaleKeys.cancel.tr(),
        isDestructive: isDestructive,
      ),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );

    // A barrier tap returns null and must read as "cancel".
    return result ?? false;
  }
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDestructive ? AppColors.danger : AppColors.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card.r),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.title,
                ),
                SizedBox(height: 10.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.body.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: cancelLabel,
                        background: AppColors.white,
                        foreground: AppColors.dark,
                        borderColor: AppColors.border,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _DialogButton(
                        label: confirmLabel,
                        background: confirmColor,
                        foreground: AppColors.white,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.input.r);

    return Material(
      color: background,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: Text(
            label,
            style: AppTextStyle.input.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
