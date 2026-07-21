import 'dart:convert';

import 'package:markdown/markdown.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/markdown/diagnostic_styles.dart';
import 'package:pluto/markdown/node_transformer.dart';

// The markdown renderer writes Text content verbatim; inline syntaxes are
// expected to pre-escape (see MarkerInlineSyntax).
const HtmlEscape _escape = HtmlEscape(HtmlEscapeMode.element);

/// Expands `{{config.<key>}}` in step prose.
///
/// An [InlineSyntax] rather than a replace over the raw source, so a value is
/// inserted as text and cannot bring markup or Markdown of its own with it.
///
/// Two contexts are invisible here and are covered elsewhere: link destinations
/// are parsed into attributes rather than [Text] ([ConfigLinkTransformer]), and
/// code is resolved before inline syntaxes run ([ConfigCodeTransformer]).
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

/// Expands `{{config.<key>}}` inside code spans and fenced blocks.
///
/// The parser resolves code before inline syntaxes run, so [ConfigInlineSyntax]
/// never reaches it. Applies only where the renderer knows it is inside code:
/// the text there is already HTML-escaped, so a substituted value has to be
/// escaped to match.
///
/// An unknown key is left exactly as written rather than badged the way prose
/// badges it — an element inside `<code>` renders as literal tag text to the
/// student. Validation reports it, and that report aborts a push.
class ConfigCodeTransformer extends TextTransformer {
  final CourseConfig? config;

  const ConfigCodeTransformer(this.config);

  @override
  List<Node> apply(Text text) {
    final config = this.config;
    if (config == null || config.isEmpty) return [text];

    return [
      Text(
        text.text.replaceAllMapped(_reference, (match) {
          final value = config.resolve(match.group(1)!);
          return value == null ? match.group(0)! : _escape.convert(value);
        }),
      ),
    ];
  }

  static final RegExp _reference = RegExp(configPattern);
}
