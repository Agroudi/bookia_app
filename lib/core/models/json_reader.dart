/// Defensive readers for the API's loosely-typed JSON.
///
/// The Book Store API is inconsistent about types across endpoints: `price`
/// arrives as `"378.00"` in one place and `294.84` in another, `total` is a
/// string on `/cart` and a number on `/remove-from-cart`, and `data` is `[]`
/// rather than `{}` on most failures. Parsing through these helpers means a
/// single surprising field degrades to a default instead of throwing a
/// `TypeError` deep inside a cubit.
extension JsonReader on Map<String, dynamic> {
  int? readInt(String key) => switch (this[key]) {
    final int value => value,
    final double value => value.round(),
    final String value =>
      int.tryParse(value) ?? double.tryParse(value)?.round(),
    _ => null,
  };

  double? readDouble(String key) => switch (this[key]) {
    final double value => value,
    final int value => value.toDouble(),
    final String value => double.tryParse(value),
    _ => null,
  };

  /// Trimmed, with empty strings collapsing to null so the UI can fall back.
  String? readString(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Tolerates `true`, `1` and `"1"` — the API uses all three for flags.
  bool readBool(String key) => switch (this[key]) {
    final bool value => value,
    final int value => value != 0,
    final String value => value == '1' || value.toLowerCase() == 'true',
    _ => false,
  };

  /// A list of objects, or empty when the key is absent or is the API's
  /// "no data" `[]`/`null`.
  List<Map<String, dynamic>> readObjectList(String key) {
    final value = this[key];
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }

  /// A nested object, or null when absent or of the wrong shape.
  Map<String, dynamic>? readObject(String key) {
    final value = this[key];
    return value is Map<String, dynamic> ? value : null;
  }
}
