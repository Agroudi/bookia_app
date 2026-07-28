import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/utils/app_keys.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// The app's single loading state: the `book_loader` Lottie, and nothing else.
///
/// No card, no scrim, no blur — the animation floats directly over whatever is
/// on screen. Input is still fully blocked: this is a modal route, so it
/// swallows every touch regardless of how the barrier is painted, and
/// [_LoadingBody] swallows the back gesture too.
///
/// It is deliberately impossible to dismiss — no barrier tap, no back button,
/// no swipe. Only the code that showed it can take it down, which is also what
/// stops a user from double-submitting a form or navigating away mid-request.
abstract final class LoadingOverlay {
  static RawDialogRoute<void>? _route;

  static bool get isVisible => _route != null;

  static void show() {
    // Re-entrancy guard: two overlapping requests must not stack two dialogs,
    // otherwise the first `hide` would leave one behind forever.
    if (isVisible) return;

    final navigator = AppKeys.navigator.currentState;
    if (navigator == null) return;

    final route = RawDialogRoute<void>(
      barrierDismissible: false,
      // Transparent, not absent: the barrier still intercepts every pointer
      // event, it just paints nothing.
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => const _LoadingBody(),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

    _route = route;
    navigator.push(route);
  }

  static void hide() {
    final route = _route;
    if (route == null) return;
    _route = null;

    // removeRoute rather than pop: by the time a request finishes the user may
    // have had another route pushed on top, and popping would dismiss theirs.
    if (route.isActive) {
      AppKeys.navigator.currentState?.removeRoute(route);
    }
  }

  /// Runs [action] with the overlay up, guaranteeing it comes down again even
  /// if [action] throws.
  static Future<T> during<T>(Future<T> Function() action) async {
    show();
    try {
      return await action();
    } finally {
      hide();
    }
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Swallows the system back gesture/button while loading.
      canPop: false,
      child: Center(
        child: Lottie.asset(
          Assets.animations.bookLoader,
          width: 160.w,
          height: 160.w,
          fit: BoxFit.contain,
          // If the composition ever fails to decode, fall back to a plain
          // spinner rather than showing nothing at all.
          errorBuilder: (_, _, _) =>
              const CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}
