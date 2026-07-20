import 'package:markdown/markdown.dart';
import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/markdown/node_transformer.dart';

/// Wraps declared abbreviations in `<abbr title="...">`, following the usual
/// convention of marking only the first use — a page where every `PL` carries a
/// tooltip is noisier than it is helpful.
///
/// A Latin term is emitted as `<abbr title="..."><em>PL</em></abbr>`:
/// [AutoItalicTransformer] never sees it (the fold in `StepikMarkdownRenderer`
/// only re-applies to nodes that are still [Text]), so the emphasis has to be
/// produced here to match the rest of the page. A term in any other script gets
/// a bare `<abbr title="...">ЯП</abbr>`, since that transformer would not have
/// italicized it either.
///
/// Matching is case-sensitive, so a term like `IT` cannot swallow the ordinary
/// word `it`. Skipping of code and already-emphasized text is handled by the
/// traversal, not here.
///
/// Unlike its siblings this transformer is stateful and must be built fresh per
/// rendered step, since "first use" is scoped to one step.
class AbbreviationTransformer implements TextTransformer {
  final Abbreviations abbreviations;

  final RegExp? _pattern;
  final Set<String> _marked = <String>{};

  AbbreviationTransformer(this.abbreviations)
    : _pattern = abbreviations.pattern;

  @override
  List<Node> apply(Text text) {
    final pattern = _pattern;
    if (pattern == null) return [text];

    final input = text.text;
    final result = <Node>[];
    var changed = false;

    void markFree(String free) {
      var from = 0;
      for (final match in pattern.allMatches(free)) {
        final term = match[0] ?? '';
        final expansion = abbreviations.resolve(term);
        if (expansion == null || !_marked.add(term)) continue;

        if (match.start > from) {
          result.add(Text(free.substring(from, match.start)));
        }
        final marked = Text(term);
        result.add(
          Element('abbr', <Node>[
            if (_latinTerm.hasMatch(term))
              Element('em', <Node>[marked])
            else
              marked,
          ])..attributes['title'] = _escapeAttribute(expansion),
        );
        from = match.end;
        changed = true;
      }
      if (from < free.length) result.add(Text(free.substring(from)));
    }

    var last = 0;
    for (final span in htmlProtectedSpans.allMatches(input)) {
      if (span.start > last) markFree(input.substring(last, span.start));
      result.add(Text(span[0] ?? ''));
      last = span.end;
    }
    if (last < input.length) markFree(input.substring(last));

    return changed ? result : [text];
  }

  /// The token shape [AutoItalicTransformer] would have wrapped. Kept in step
  /// with its `_phrase`: a Cyrillic term is never italicized there, so
  /// italicizing it here would leave it the only italic Cyrillic on the page.
  static final RegExp _latinTerm = RegExp(
    r'^[A-Za-z0-9]+(?:[./\-][A-Za-z0-9]+)*$',
  );

  /// The renderer writes attribute values verbatim, so an expansion containing
  /// a quote or an ampersand would otherwise produce broken markup.
  static String _escapeAttribute(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
