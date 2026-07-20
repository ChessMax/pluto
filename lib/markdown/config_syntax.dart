import 'dart:convert';

import 'package:markdown/markdown.dart';
import 'package:pluto/domain/course_config.dart';

// The markdown renderer writes Text content verbatim; inline syntaxes are
// expected to pre-escape (see MarkerInlineSyntax).
const HtmlEscape _escape = HtmlEscape(HtmlEscapeMode.element);

/// Expands `{{config.<key>}}` in step Markdown.
///
/// Deliberately an [InlineSyntax] rather than a replace over the raw source: by
/// the time inline syntaxes run, the parser has already decided what is a code
/// span or fenced block, and never runs them there. A course about programming
/// is full of `{{ }}` in Vue/Jinja/Handlebars samples, and those must survive
/// verbatim without authors escaping anything.
///
/// Link destinations are not [Text] and so are invisible here — they are handled
/// by [ConfigLinkTransformer].
class ConfigInlineSyntax extends InlineSyntax {
  final CourseConfig? config;

  ConfigInlineSyntax(this.config)
    : super(configPattern, startCharacter: 0x7B /* { */);

  @override
  bool onMatch(InlineParser parser, Match match) {
    // Unknown key: re-emit the reference verbatim for validation to report.
    //
    // Never `return false` here: the pattern has already matched, and declining
    // leaves the parser's position unchanged, so it matches again forever.
    final value = config?.resolve(match[1]!) ?? match[0]!;

    parser.addNode(Text(parser.encodeHtml ? _escape.convert(value) : value));
    return true;
  }
}
