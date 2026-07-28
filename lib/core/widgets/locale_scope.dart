import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Rebuilds the page it wraps whenever the app locale changes.
///
/// The Navigator caches each route's page widget, so a route only rebuilds
/// when an inherited widget *it depends on* changes. Screens translate with
/// `LocaleKeys.x.tr()`, which is a plain function call and creates no such
/// dependency. Without this, switching language mirrors the layout — because
/// `Directionality` is inherited and does propagate — while leaving every
/// translated string showing the previous locale.
///
/// Reading `context.locale` here subscribes this element to the localization
/// provider, and calling [builder] produces a fresh page instance on every
/// rebuild, which is what forces the subtree's `build` methods to re-run.
/// The navigation stack and each screen's state are preserved.
class LocaleScope extends StatelessWidget {
  const LocaleScope({super.key, required this.builder});

  /// Must return a **non-const** widget. A const instance is canonicalised,
  /// so Flutter would see an identical child and skip the rebuild entirely.
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    // Subscribe: this is the whole point of the widget.
    context.locale;
    return builder();
  }
}
