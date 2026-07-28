import 'package:bookia_app/core/services/app_toast.dart';
import 'package:bookia_app/core/widgets/app_dialog.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Guards the app against an accidental exit.
///
/// Wrap the *root* route with this. A back gesture never closes the app on its
/// own:
///   1. first back  — a toast warns that another back will exit;
///   2. second back within [window] — a confirmation dialog, which the user is
///      free to cancel;
///   3. only "Exit" in that dialog actually closes the app.
///
/// The counter resets after [window] so a stray back press half a minute ago
/// can't combine with a fresh one to trigger the dialog.
class ExitConfirmationScope extends StatefulWidget {
  const ExitConfirmationScope({
    super.key,
    required this.child,
    this.onBack,
    this.window = const Duration(seconds: 3),
  });

  final Widget child;

  /// Gives the host a chance to consume the back press first — the shell uses
  /// it to return to the Home tab instead of starting the exit flow.
  ///
  /// Return true when the press was handled; the exit sequence is then skipped
  /// and its counter reset. This is a callback rather than a second nested
  /// [PopScope] because every `PopScope` on a route fires, so nesting them
  /// would run both behaviours on a single press.
  final bool Function()? onBack;

  final Duration window;

  @override
  State<ExitConfirmationScope> createState() => _ExitConfirmationScopeState();
}

class _ExitConfirmationScopeState extends State<ExitConfirmationScope> {
  DateTime? _firstBackAt;

  /// Guards against the dialog being opened twice by a rapid double-back.
  bool _isAsking = false;

  bool get _isWithinWindow {
    final first = _firstBackAt;
    if (first == null) return false;
    return DateTime.now().difference(first) <= widget.window;
  }

  Future<void> _handleBack() async {
    if (_isAsking) return;

    if (widget.onBack?.call() ?? false) {
      _firstBackAt = null;
      return;
    }

    if (!_isWithinWindow) {
      _firstBackAt = DateTime.now();
      AppToast.info(LocaleKeys.press_back_again.tr());
      return;
    }

    _firstBackAt = null;
    _isAsking = true;
    AppToast.dismissAll();

    try {
      final shouldExit = await AppDialog.confirm(
        context,
        title: LocaleKeys.exit_app_title.tr(),
        message: LocaleKeys.exit_app_message.tr(),
        confirmLabel: LocaleKeys.exit.tr(),
        isDestructive: true,
      );
      if (shouldExit) await SystemNavigator.pop();
    } finally {
      if (mounted) _isAsking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Never let the framework pop the root route; we decide.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: widget.child,
    );
  }
}
