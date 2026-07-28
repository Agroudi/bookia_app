import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/services/app_toast.dart';
import 'package:bookia_app/core/services/loading_overlay.dart';
import 'package:easy_localization/easy_localization.dart';

/// The standard reaction to a cubit state.
///
/// Every screen funnels through these three calls so loading, errors and
/// confirmations behave identically everywhere: the Lottie overlay for work in
/// progress, a glacier toast for the outcome.
abstract final class StateFeedback {
  static void loading() => LoadingOverlay.show();

  /// Dismisses the overlay and reports the failure.
  ///
  /// A [ValidationFailure] is *not* toasted when the form can show it inline —
  /// pass `silent: true` in that case, otherwise the user gets the same
  /// message twice.
  static void failure(AppFailure failure, {bool silent = false}) {
    LoadingOverlay.hide();
    if (silent) return;

    switch (failure) {
      case NetworkFailure():
        AppToast.warning(failure.message);
      case ValidationFailure():
        AppToast.error(failure.message);
      case UnauthorizedFailure():
        AppToast.error(failure.message);
      case NotFoundFailure():
        AppToast.info(failure.message);
      case ServerFailure():
      case UnknownFailure():
        AppToast.error(failure.message);
    }
  }

  /// Dismisses the overlay and confirms.
  ///
  /// [serverMessage] wins when present — the API returns useful, already
  /// localised copy such as "Product Added To Cart" — falling back to
  /// [fallbackKey] when it is empty.
  static void success(String? serverMessage, {String? fallbackKey}) {
    LoadingOverlay.hide();
    final message = (serverMessage != null && serverMessage.isNotEmpty)
        ? serverMessage
        : fallbackKey?.tr();
    if (message != null) AppToast.success(message);
  }

  /// Dismisses the overlay without saying anything — for a success whose
  /// result is self-evident on screen.
  static void done() => LoadingOverlay.hide();
}
