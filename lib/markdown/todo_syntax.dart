import 'dart:convert';

import 'package:markdown/markdown.dart';

/// Inline `[[TODO: message]]` marker.
///
/// Source: `[[TODO: add a screenshot here]]`
const String todoPattern = r'\[\[TODO:\s*(.+?)\]\]';

const String _emoji = '⚠️';
const String _style =
    'background-color:#fff3cd;color:#856404;padding:2px 4px;border-radius:3px;';

// The markdown renderer writes Text content verbatim; inline syntaxes are
// expected to pre-escape, so the message is escaped here (see ColorSwatchSyntax).
const HtmlEscape _escape = HtmlEscape(HtmlEscapeMode.element);

class TodoInlineSyntax extends InlineSyntax {
  TodoInlineSyntax() : super(todoPattern, startCharacter: 0x5B /* [ */);

  @override
  bool onMatch(InlineParser parser, Match match) {
    final message = match[1]!.trim();
    final escaped = parser.encodeHtml ? _escape.convert(message) : message;

    parser.addNode(
      Element('span', [
        Text('$_emoji '),
        Element('strong', [Text('TODO: $escaped')]),
      ])..attributes['style'] = _style,
    );

    return true;
  }
}
