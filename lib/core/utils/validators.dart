import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

/// Client-side form validation.
///
/// The server validates too — these rules exist to catch bad input before it
/// costs a round trip, to keep obviously abusive payloads (megabyte-long
/// "names", control characters) off the wire, and to give the user an error in
/// their own language immediately.
abstract final class Validators {
  /// Deliberately stricter than the RFC: one `@`, a dotted domain, no spaces.
  static final RegExp _email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$",
  );

  /// Letters (Latin or Arabic), spaces, apostrophes and hyphens.
  static final RegExp _personName = RegExp(r"^[\p{L}\s'\-\.]+$", unicode: true);

  static final RegExp _digits = RegExp(r'^\d+$');
  static final RegExp _hasLetter = RegExp(r'[a-zA-Z\p{L}]', unicode: true);
  static final RegExp _hasDigit = RegExp(r'\d');

  /// Upper bounds on every free-text field. Stops a pathological paste from
  /// being sent to the API at all.
  static const int maxName = 60;
  static const int maxEmail = 120;
  static const int maxPassword = 64;
  static const int maxAddress = 200;
  static const int maxSubject = 120;
  static const int maxMessage = 1000;
  static const int maxSearch = 60;

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return LocaleKeys.email_required.tr();
    if (input.length > maxEmail) return LocaleKeys.field_too_long.tr();
    if (!_email.hasMatch(input)) return LocaleKeys.email_invalid.tr();
    return null;
  }

  /// For sign-in: only checks presence. Strength rules belong on the screens
  /// that *set* a password, otherwise a user whose old password predates the
  /// rules can no longer log in.
  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return LocaleKeys.password_required.tr();
    return null;
  }

  /// For register / reset / change password.
  static String? newPassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) return LocaleKeys.password_required.tr();
    if (input.length < 8) return LocaleKeys.password_too_short.tr();
    if (input.length > maxPassword) return LocaleKeys.field_too_long.tr();
    if (!_hasLetter.hasMatch(input) || !_hasDigit.hasMatch(input)) {
      return LocaleKeys.password_needs_letter_and_number.tr();
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return LocaleKeys.password_required.tr();
    if (value != original) return LocaleKeys.password_mismatch.tr();
    return null;
  }

  static String? name(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return LocaleKeys.name_required.tr();
    if (input.length < 3) return LocaleKeys.name_too_short.tr();
    if (input.length > maxName) return LocaleKeys.field_too_long.tr();
    if (!_personName.hasMatch(input)) return LocaleKeys.name_invalid.tr();
    return null;
  }

  /// Egyptian mobile format, matching the API's sample data (11 digits).
  /// Tolerates spaces and dashes; strip with [digitsOnly] before sending.
  static String? phone(String? value) {
    final input = digitsOnly(value ?? '');
    if (input.isEmpty) return LocaleKeys.phone_required.tr();
    if (input.length != 11 || !_digits.hasMatch(input)) {
      return LocaleKeys.phone_invalid.tr();
    }
    return null;
  }

  static String? address(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return LocaleKeys.address_required.tr();
    if (input.length < 5) return LocaleKeys.address_too_short.tr();
    if (input.length > maxAddress) return LocaleKeys.field_too_long.tr();
    return null;
  }

  static String? city(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return LocaleKeys.city_required.tr();
    if (input.length > maxName) return LocaleKeys.field_too_long.tr();
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    final input = digitsOnly(value ?? '');
    if (input.isEmpty) return LocaleKeys.code_required.tr();
    if (input.length != length) return LocaleKeys.code_invalid.tr();
    return null;
  }

  static String? subject(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return LocaleKeys.subject_required.tr();
    if (input.length > maxSubject) return LocaleKeys.field_too_long.tr();
    return null;
  }

  static String? message(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return LocaleKeys.message_required.tr();
    if (input.length < 10) return LocaleKeys.message_too_short.tr();
    if (input.length > maxMessage) return LocaleKeys.field_too_long.tr();
    return null;
  }

  /// Strips everything that isn't a digit, and normalises Arabic-Indic
  /// numerals so a phone typed on an Arabic keyboard still validates.
  static String digitsOnly(String value) {
    const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final arabicIndex = arabicIndic.indexOf(char);
      if (arabicIndex != -1) {
        buffer.write(arabicIndex);
      } else if (char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Collapses runs of whitespace and trims. Applied before any string is
  /// sent to the API.
  static String sanitize(String value, {int? maxLength}) {
    final cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (maxLength != null && cleaned.length > maxLength) {
      return cleaned.substring(0, maxLength);
    }
    return cleaned;
  }
}
