import 'package:flutter/material.dart';

/// App-wide keys.
///
/// The navigator key lets non-widget code — the Dio auth interceptor, the
/// loading overlay, the toast service — reach a `BuildContext` without every
/// repository having to thread one through.
abstract final class AppKeys {
  static final GlobalKey<NavigatorState> navigator =
      GlobalKey<NavigatorState>();

  /// The context of the topmost route, or null before the first frame.
  static BuildContext? get context => navigator.currentContext;
}
