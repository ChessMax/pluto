import 'dart:convert';

import 'package:markdown/markdown.dart';
import 'package:pluto/domain/marker_scanner.dart';

/// Inline `[[<keyword>: message]]` marker, e.g. `[[TODO: add a screenshot]]`.
///
/// Rendering follows the marker's severity: `info` markers are author-only and
/// are stripped entirely, so they never reach students; louder ones render as a
/// coloured badge. Keywords and severities come from [markerKinds].

const String _warningStyle =
    'background-color:#fff3cd;color:#856404;padding:2px 4px;border-radius:3px;';
const String _errorStyle =
    'background-color:#f8d7da;color:#721c24;padding:2px 4px;border-radius:3px;';

// The markdown renderer writes Text content verbatim; inline syntaxes are
// expected to pre-escape, so the message is escaped here (see ColorSwatchSyntax).
const HtmlEscape _escape = HtmlEscape(HtmlEscapeMode.element);

final Map<String, MarkerKind> _byKeyword = {
  for (final kind in markerKinds) kind.keyword: kind,
};

class MarkerInlineSyntax extends InlineSyntax {
  MarkerInlineSyntax() : super(markerPattern, startCharacter: 0x5B /* [ */);

  @override
  bool onMatch(InlineParser parser, Match match) {
    final kind = _byKeyword[match[1]];
    if (kind == null) return false;

    final badge = switch (kind.severity) {
      .info => null,
      .warning => ('⚠️', _warningStyle),
      .error => ('⛔', _errorStyle),
    };

    // Author-only: consume the marker but emit nothing.
    if (badge == null) return true;

    final (emoji, style) = badge;
    final message = match[2]!.trim();
    final escaped = parser.encodeHtml ? _escape.convert(message) : message;

    parser.addNode(
      Element('span', [
        Text('$emoji '),
        Element('strong', [Text('${kind.keyword}: $escaped')]),
      ])..attributes['style'] = style,
    );

    return true;
  }
}
