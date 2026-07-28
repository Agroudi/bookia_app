import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

/// Direction resolution for text that comes from the API.
///
/// Catalogue content is authored independently of the app's locale — the book
/// descriptions on this backend are English regardless of whether the user
/// picked Arabic. Rendering an English paragraph inside an RTL
/// [Directionality] right-aligns it and pushes trailing punctuation to the
/// front (".your career"), so any Text showing server prose should take its
/// direction from the *content*, not the UI.
abstract final class AppBidi {
  /// The direction implied by [text], or null when it has no strong
  /// directional characters and the ambient direction should win.
  static TextDirection? directionOf(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return intl.Bidi.detectRtlDirectionality(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Alignment that matches [directionOf], for widgets that need both.
  static TextAlign alignFor(String? text) =>
      directionOf(text) == TextDirection.rtl ? TextAlign.right : TextAlign.left;
}
