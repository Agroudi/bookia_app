import 'package:flutter/material.dart';

/// Colour tokens taken verbatim from the Bookia Figma file.
///
/// Every value here maps to a named fill style in the design; nothing is
/// invented. Keep this list closed — screens must not hardcode hex values.
abstract final class AppColors {
  /// Brand gold. Primary buttons, active nav icon, accents.
  static const Color primary = Color(0xFFBFA054);

  /// Primary text / dark buttons ("Buy", "Add To Cart").
  static const Color dark = Color(0xFF2F2F2F);

  /// Scaffold background for every screen.
  static const Color background = Color(0xFFF7F8F9);

  /// Card and input borders.
  static const Color border = Color(0xFFE8ECF4);

  static const Color white = Color(0xFFFFFFFF);

  /// Input hint text.
  static const Color hint = Color(0xFF8391A1);

  /// Muted icons (password eye).
  static const Color iconMuted = Color(0xFF6A707C);

  /// Headings inside cards / amounts.
  static const Color heading = Color(0xFF303030);

  /// List-row labels (profile menu, cart item title).
  static const Color label = Color(0xFF606060);

  /// Secondary text (dates, "Total:", descriptions).
  static const Color secondaryText = Color(0xFF808080);

  /// Delivered / success states.
  static const Color success = Color(0xFF27AE60);

  /// Destructive: the wishlist & cart remove badge.
  static const Color danger = Color(0xFFFF3A2E);

  /// Disabled field fill / unread notification row.
  static const Color disabledField = Color(0xFFF5F5F5);

  /// Hairline dividers inside cards.
  static const Color divider = Color(0xFFF0F0F0);

  /// Image placeholders before the network image resolves.
  static const Color placeholder = Color(0xFFD9D9D9);
  static const Color placeholderDark = Color(0xFFC4C4C4);

  /// Dropdown chevron on the Place Order form.
  static const Color dropdownArrow = Color(0xFF919EAC);
}

/// Corner radii used by the design. Named after where they appear so a
/// mismatch is obvious at the call site.
abstract final class AppRadius {
  /// Inputs, primary buttons, book detail cover.
  static const double input = 8;

  /// Book cards, cart rows.
  static const double card = 10;

  /// Back button.
  static const double backButton = 12;

  /// Profile menu rows, order cards, quantity stepper buttons.
  static const double tile = 6;

  /// "Buy" pill, checkout button.
  static const double pill = 4;

  /// Search field.
  static const double searchField = 15;

  /// Bottom sheets.
  static const double sheet = 30;
}

/// Horizontal page insets. The design is not perfectly consistent
/// (16/20/24 across screens); these are the three real values.
abstract final class AppSpacing {
  static const double screenTight = 16;
  static const double screen = 20;
  static const double screenWide = 24;
}
