/// Turns the API's HTML product descriptions into plain text.
///
/// `/products/{id}` returns markup — `<p>Master the math…&nbsp;</p>` — which
/// renders literally in a `Text`, and worse under an Arabic locale where bidi
/// reorders the stray angle brackets to `p>…</p`. Stripping is enough here:
/// the descriptions are prose with no structure worth preserving.
abstract final class HtmlText {
  static final RegExp _tag = RegExp(r'<[^>]*>');
  static final RegExp _whitespace = RegExp(r'\s+');

  /// Named and numeric entities the API actually emits.
  static const Map<String, String> _entities = {
    '&nbsp;': ' ',
    '&amp;': '&',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&apos;': "'",
    '&#39;': "'",
    '&hellip;': '…',
    '&mdash;': '—',
    '&ndash;': '–',
    '&rsquo;': '’',
    '&lsquo;': '‘',
    '&ldquo;': '“',
    '&rdquo;': '”',
  };

  static String? strip(String? html) {
    if (html == null) return null;

    var text = html;
    // Block-level tags become paragraph breaks so the prose keeps its shape.
    text = text.replaceAll(
      RegExp(r'</\s*(p|div|br|li|h[1-6])\s*/?>', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(_tag, '');

    for (final entry in _entities.entries) {
      text = text.replaceAll(entry.key, entry.value);
    }
    // Any remaining numeric entity, e.g. &#8217;
    text = text.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) => String.fromCharCode(int.parse(match.group(1)!)),
    );

    // Collapse the whitespace the markup left behind, but keep paragraphs.
    text = text
        .split('\n')
        .map((line) => line.replaceAll(_whitespace, ' ').trim())
        .where((line) => line.isNotEmpty)
        .join('\n\n');

    return text.isEmpty ? null : text;
  }
}
