/// Acronyms declared once and expanded to `<abbr title="...">` wherever they
/// appear in step Markdown, so an author writes `PL` and the reader still gets
/// the full wording on hover.
///
/// Declared in `source/abbreviations.md`, a file of nothing but front matter:
///
/// ```yaml
/// ---
/// PL: Programming Language
/// HTTP: HyperText Transfer Protocol
/// ---
/// ```
class Abbreviations {
  /// Term to its expansion, e.g. `PL` -> `Programming Language`.
  final Map<String, String> values;

  const Abbreviations(this.values);

  static const Abbreviations empty = Abbreviations(<String, String>{});

  bool get isEmpty => values.isEmpty;
  bool get isNotEmpty => values.isNotEmpty;

  String? resolve(String term) => values[term];

  /// Reads the front matter of `abbreviations.md`, whose every top-level key is
  /// a term.
  ///
  /// Scalars are stringified so an expansion need not be quoted; a null value is
  /// dropped rather than rendered as the text "null". Nested maps and lists are
  /// rejected: an expansion becomes a `title` attribute, so there is nothing
  /// sensible to substitute for them.
  static Abbreviations fromYaml(dynamic node) {
    if (node == null) return empty;
    if (node is! Map) {
      throw 'abbreviations.md: front matter must be a map of term/expansion '
          'pairs';
    }

    final values = <String, String>{};
    for (final entry in node.entries) {
      final term = entry.key.toString();
      if (!_termPattern.hasMatch(term)) {
        throw 'abbreviations.md: invalid term `$term` (letters and digits of '
            'any script, optionally joined by `.`, `/`, `-` or `_`)';
      }

      final expansion = entry.value;
      switch (expansion) {
        case null:
          continue;
        case Map() || Iterable():
          throw 'abbreviations.md: expansion of `$term` must be a scalar';
        default:
          values[term] = expansion.toString();
      }
    }

    return Abbreviations(values);
  }

  /// The whole of `abbreviations.md`, or an empty string when nothing is
  /// declared — a course without acronyms gets no file at all.
  ///
  /// An expansion is quoted only when writing it bare would change what YAML
  /// reads back, so a hand-written file keeps its plain style across a rewrite.
  String toFrontMatter() {
    if (values.isEmpty) return '';
    final lines = [
      '---',
      for (final entry in values.entries)
        '${entry.key}: ${_quoteIfNeeded(entry.value)}',
      '---',
    ];
    return '${lines.join('\n')}\n';
  }

  /// A plain scalar cannot start with an indicator character, contain `: ` or
  /// ` #`, or carry outer spaces; single quotes make any of those literal, with
  /// `''` escaping a quote of its own.
  static String _quoteIfNeeded(String value) {
    final needsQuotes =
        value.isEmpty ||
        value.trim() != value ||
        value.contains(': ') ||
        value.contains(' #') ||
        value.endsWith(':') ||
        _indicators.hasMatch(value);
    if (!needsQuotes) return value;
    return "'${value.replaceAll("'", "''")}'";
  }

  static final RegExp _indicators = RegExp(r'''^[-?:,\[\]{}#&*!|>'"%@`]''');

  /// Matches any declared term as a whole word, or null when nothing is
  /// declared.
  ///
  /// Terms are ordered longest-first so a shorter one can never shadow a longer
  /// one sharing its prefix (regex alternation is first-match, not
  /// longest-match).
  ///
  /// Memoized against the declaring map: every rendered step builds an
  /// [AbbreviationTransformer], which reads this once, so a course of any size
  /// would otherwise recompile the same alternation per step. The cache is
  /// external because the const constructor rules out a `late final` field.
  RegExp? get pattern {
    if (values.isEmpty) return null;
    return _patterns[values] ??= _buildPattern();
  }

  RegExp _buildPattern() {
    final terms = values.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // Lookarounds rather than `\b`: Dart inherits JavaScript's ASCII-only `\w`,
    // so `\bЯП\b` matches nothing at all — a Cyrillic letter is not a word
    // character, leaving no boundary for `\b` to sit on.
    return RegExp(
      r'(?<![\p{L}\p{N}_])(?:' +
          terms.map(RegExp.escape).join('|') +
          r')(?![\p{L}\p{N}_])',
      unicode: true,
    );
  }

  static final Expando<RegExp> _patterns = Expando<RegExp>();

  /// A term has to sit on a word boundary to be matchable at all, which rules
  /// out leading/trailing punctuation; internal `./-_` is kept so `HTTP/2` and
  /// `well-known` work.
  ///
  /// Any script counts, not just Latin: a course written in Russian abbreviates
  /// in Russian (`ЯП`, `ПО`).
  static final RegExp _termPattern = RegExp(
    r'^[\p{L}\p{N}]+(?:[./\-_][\p{L}\p{N}]+)*$',
    unicode: true,
  );
}
