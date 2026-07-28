import 'package:easy_localization/easy_localization.dart';

/// Money formatting.
///
/// The design is inconsistent about currency — book cards and Book Details
/// show `₹`, while Cart, Order History and Order Details show `$`. The API
/// sends bare numbers and no currency code at all, so the app picks one symbol
/// and uses it everywhere rather than reproducing the mismatch.
abstract final class PriceFormat {
  static const String symbol = r'$';

  static String format(double value) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: _decimalsFor(value),
      // Latin digits in both locales: the API's own order codes and totals are
      // Latin, and mixing numeral systems in one column reads badly.
      locale: 'en',
    );
    return formatter.format(value);
  }

  /// Whole amounts lose the ".00"; anything with a fraction keeps two places.
  static int _decimalsFor(double value) =>
      value == value.roundToDouble() ? 0 : 2;
}
