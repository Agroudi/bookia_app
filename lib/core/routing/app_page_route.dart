import 'package:flutter/material.dart';

/// Shared screen transitions.
///
/// One place for motion so every push in [AppRouter] feels the same, and so
/// the curve/duration can be tuned globally rather than per route.
abstract final class AppPageRoute {
  static const Duration _duration = Duration(milliseconds: 380);
  static const Duration _reverse = Duration(milliseconds: 300);

  /// Default push: the incoming page slides in from the trailing edge while
  /// the outgoing one drifts back and fades. Direction-aware, so it slides
  /// from the left under an Arabic (RTL) locale.
  static Route<T> slide<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: _duration,
      reverseTransitionDuration: _reverse,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (context, animation, secondary, child) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final begin = Offset(isRtl ? -1 : 1, 0);

        final enter = Tween<Offset>(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        final exit =
            Tween<Offset>(
              begin: Offset.zero,
              end: Offset(isRtl ? 0.22 : -0.22, 0),
            ).animate(
              CurvedAnimation(parent: secondary, curve: Curves.easeOutCubic),
            );

        return SlideTransition(
          position: exit,
          child: SlideTransition(
            position: enter,
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
    );
  }

  /// Fade + a subtle scale. Used for roots (splash -> layout) where a
  /// horizontal slide would imply a hierarchy that isn't there.
  static Route<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: _duration,
      reverseTransitionDuration: _reverse,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Rises from the bottom. For detail screens presented as a sheet-like push
  /// (book details, order details).
  static Route<T> rise<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: _duration,
      reverseTransitionDuration: _reverse,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.12),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}
