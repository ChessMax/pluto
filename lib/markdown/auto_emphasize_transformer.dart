import 'package:markdown/markdown.dart';
import 'package:pluto/markdown/node_transformer.dart';

/// Wraps Latin/number phrases in `<em>`, so English words and numbers are
/// rendered italic without any special Markdown syntax.
///
/// A phrase is a run of alphanumeric tokens joined by single spaces; sentence
/// punctuation breaks the run (`foo, bar` -> `<em>foo</em>, <em>bar</em>`),
/// while internal `.`/`/`/`-` keep versions and decimals together (`3.14`,
/// `v2.0`, `HTTP/2`, `well-known`).
///
/// Cyrillic is never wrapped. Skipping of code and already-emphasized text is
/// handled by the traversal, not here.
class AutoItalicTransformer implements TextTransformer {
  const AutoItalicTransformer();

  // TODO: these regexes are unreadable. Probably it would be better to replace
  //  with actual parsing?

  // token: alphanumerics with internal ./-/ glue (versions, decimals, compounds)
  // phrase: tokens joined by single spaces; other punctuation breaks the run
  // TODO(cyrillic): decide behavior for digits glued to Cyrillic, e.g. "5кг".
  //   Currently the leading "5" is wrapped and "кг" is left untouched; revisit.
  static final _phrase = RegExp(
    r'[A-Za-z0-9]+(?:[./\-][A-Za-z0-9]+)*(?: [A-Za-z0-9]+(?:[./\-][A-Za-z0-9]+)*)*',
  );

  static final _protected = htmlProtectedSpans;

  @override
  List<Node> apply(Text text) {
    final input = text.text;
    final result = <Node>[];
    var changed = false;

    void wrapFree(String free) {
      var from = 0;
      for (final match in _phrase.allMatches(free)) {
        if (match.start > from) {
          result.add(Text(free.substring(from, match.start)));
        }
        result.add(Element('em', <Node>[Text(match[0] ?? '')]));
        from = match.end;
        changed = true;
      }
      if (from < free.length) result.add(Text(free.substring(from)));
    }

    var last = 0;
    for (final span in _protected.allMatches(input)) {
      if (span.start > last) wrapFree(input.substring(last, span.start));
      result.add(Text(span[0] ?? ''));
      last = span.end;
    }
    if (last < input.length) wrapFree(input.substring(last));

    return changed ? result : [text];
  }
}
