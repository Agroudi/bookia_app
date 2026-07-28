import 'package:bookia_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Font families bundled in `pubspec.yaml`.
abstract final class AppFonts {
  /// The design's display family. Latin glyphs only.
  static const String display = 'DMSerif-Regular';

  /// Numeric / UI family — cart totals, order cards, notifications.
  static const String ui = 'NunitoSans';

  /// Arabic. DM Serif Display and Nunito Sans both lack Arabic glyphs, so
  /// Cairo is registered as a *fallback* rather than swapped in per-locale:
  /// Flutter resolves fallbacks per glyph, which means a mixed string like
  /// "الطلب #00051" keeps Latin digits in the primary font and renders the
  /// Arabic run in Cairo. No locale plumbing required.
  static const List<String> fallback = ['Cairo'];
}

/// The type scale, transcribed from the Figma text styles.
///
/// Sizes use `.sp` against a 375x812 design size, so they track the device's
/// text-scale setting. Line heights are expressed as a ratio of the font size
/// because that is what Flutter's `height` expects — the comment on each entry
/// records the raw Figma value it came from.
abstract final class AppTextStyle {
  static TextStyle _display(
    double size,
    double lineHeightPx, {
    Color color = AppColors.dark,
    double letterSpacing = 0,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: size.sp,
    height: lineHeightPx / size,
    letterSpacing: letterSpacing,
    fontWeight: weight,
    color: color,
  );

  static TextStyle _ui(
    double size,
    double lineHeightPx,
    FontWeight weight, {
    Color color = AppColors.heading,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: AppFonts.ui,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: size.sp,
    height: lineHeightPx / size,
    letterSpacing: letterSpacing,
    fontWeight: weight,
    color: color,
  );

  // ---------------------------------------------------------------- display

  /// 30/39, ls -0.3 — "New Password", "Place Your Order".
  static TextStyle get headlineLarge => _display(30, 39, letterSpacing: -0.3);

  /// 24/31, ls -0.24 — screen titles: Wishlist, My Cart, Profile, Best Seller.
  static TextStyle get headline => _display(24, 31, letterSpacing: -0.24);

  /// 22/30 — the "Bookia" wordmark.
  static TextStyle get wordmark => _display(22, 30);

  /// 20/27 — section titles, primary button labels, book detail title.
  static TextStyle get title => _display(20, 27);

  /// 18/25 — book card title, profile menu row.
  static TextStyle get subtitle => _display(18, 25);

  /// 16/22 — price on cards, form subtitles.
  static TextStyle get body => _display(16, 22);

  /// 15/19 — input text and hints.
  static TextStyle get input => _display(15, 19);

  /// 14/20 — the small "Buy" pill.
  static TextStyle get caption => _display(14, 20);

  /// 12/22, justified — the book description block.
  static TextStyle get description => _display(12, 22);

  // --------------------------------------------------------------------- ui

  /// Nunito Sans 700 20/27 — "Total:" and the amount beside it.
  static TextStyle get totalLabel =>
      _ui(20, 27, FontWeight.w700, color: AppColors.secondaryText);

  static TextStyle get totalValue => _ui(20, 27, FontWeight.w700);

  /// Nunito Sans 600 16/22 — order card rows, "Detail" button, status.
  static TextStyle get orderBody => _ui(16, 22, FontWeight.w600);

  /// Nunito Sans 400 14/19 — order date.
  static TextStyle get orderMeta =>
      _ui(14, 19, FontWeight.w400, color: AppColors.secondaryText);

  /// Nunito Sans 600 18/25, ls 0.9 — quantity in the cart stepper.
  static TextStyle get quantity =>
      _ui(18, 25, FontWeight.w600, color: AppColors.dark, letterSpacing: 0.9);

  /// Nunito Sans 800 14/19 — the green "New" badge.
  static TextStyle get badge =>
      _ui(14, 19, FontWeight.w800, color: AppColors.success);
}
