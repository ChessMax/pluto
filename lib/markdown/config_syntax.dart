import 'dart:convert';

import 'package:markdown/markdown.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/markdown/diagnostic_styles.dart';

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
    // Never `return false` here: the pattern has already matched, and declining
    // leaves the parser's position unchanged, so it matches again forever.
    final value = config?.resolve(match[1]!);
    if (value != null) {
      parser.addNode(Text(parser.encodeHtml ? _escape.convert(value) : value));
      return true;
    }

    // Unknown key: re-emit the reference verbatim, badged so it is impossible to
    // read past. Validation reports it too, and that report aborts a push, so
    // this never reaches students.
    final reference = match[0]!;
    parser.addNode(
      Element('span', [
        Text(parser.encodeHtml ? _escape.convert(reference) : reference),
      ])..attributes['style'] = errorStyle,
    );
    return true;
  }
}
