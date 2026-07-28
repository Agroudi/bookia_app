import 'dart:ui';

import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

enum ToastKind { success, error, info, warning }

extension on ToastKind {
  Color get accent => switch (this) {
    ToastKind.success => AppColors.success,
    ToastKind.error => AppColors.danger,
    ToastKind.info => AppColors.primary,
    ToastKind.warning => const Color(0xFFFF9500),
  };

  IconData get icon => switch (this) {
    ToastKind.success => Icons.check_rounded,
    ToastKind.error => Icons.close_rounded,
    ToastKind.info => Icons.info_outline_rounded,
    ToastKind.warning => Icons.warning_amber_rounded,
  };
}

/// Every user-facing message goes through here.
///
/// The look is "glacier": a frosted, translucent slab that blurs whatever is
/// behind it, with a coloured accent rail on the leading edge carrying the
/// state. It reads as one component across all four states rather than four
/// differently-coloured banners.
abstract final class AppToast {
  /// Toasts stack top-centre; anything older than this is dropped so a burst
  /// of failures can't cover the screen.
  static const int _maxVisible = 3;
  static const Duration _duration = Duration(seconds: 3);

  /// Live toasts, oldest first. The package exposes no count of its own, so
  /// we track what we opened in order to evict the oldest.
  static final List<ToastificationItem> _live = [];

  static void success(String message, {String? title}) =>
      _show(ToastKind.success, message, title);

  static void error(String message, {String? title}) =>
      _show(ToastKind.error, message, title);

  static void info(String message, {String? title}) =>
      _show(ToastKind.info, message, title);

  static void warning(String message, {String? title}) =>
      _show(ToastKind.warning, message, title);

  static void dismissAll() {
    _live.clear();
    toastification.dismissAll();
  }

  static void _show(ToastKind kind, String message, String? title) {
    final context = AppKeys.context;
    // Fired from a repository before the first frame; nothing to attach to.
    if (context == null || message.trim().isEmpty) return;

    while (_live.length >= _maxVisible) {
      toastification.dismissById(_live.removeAt(0).id);
    }

    final item = toastification.showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: _duration,
      animationDuration: const Duration(milliseconds: 350),
      animationBuilder: (context, animation, alignment, child) {
        // Slide down from just above the notch while fading in.
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.6),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      builder: (context, item) =>
          _GlacierToast(kind: kind, title: title, message: message, item: item),
      callbacks: ToastificationCallbacks(
        onAutoCompleteCompleted: _live.remove,
        onDismissed: _live.remove,
      ),
    );

    _live.add(item);
  }
}

class _GlacierToast extends StatelessWidget {
  const _GlacierToast({
    required this.kind,
    required this.title,
    required this.message,
    required this.item,
  });

  final ToastKind kind;
  final String? title;
  final String message;
  final ToastificationItem item;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screen.w,
        vertical: 8.h,
      ),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.up,
        onDismissed: (_) => toastification.dismissById(item.id),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400.w),
              decoration: BoxDecoration(
                // Frosted white, not opaque — the blur behind it is what
                // sells the effect.
                color: AppColors.white.withValues(alpha: 0.72),
                borderRadius: radius,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dark.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Accent rail — the only thing that changes per state.
                    Container(width: 5.w, color: kind.accent),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 28.w,
                              height: 28.w,
                              decoration: BoxDecoration(
                                color: kind.accent.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                kind.icon,
                                size: 17.sp,
                                color: kind.accent,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (title != null && title!.isNotEmpty) ...[
                                    Text(
                                      title!,
                                      style: AppTextStyle.orderBody.copyWith(
                                        color: AppColors.heading,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                  ],
                                  Text(
                                    message,
                                    style: AppTextStyle.orderMeta.copyWith(
                                      color: AppColors.dark,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
