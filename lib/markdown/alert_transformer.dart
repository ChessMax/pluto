import 'package:markdown/markdown.dart';
import 'package:pluto/markdown/node_transformer.dart';

/// A GitHub alert kind, `> [!NOTE]`, with the way it is presented to students.
class AlertKind {
  /// The type as written in the source and emitted by `AlertBlockSyntax` as a
  /// `markdown-alert-<type>` class.
  final String type;

  final String label;
  final String emoji;

  /// The accent bar colour, GitHub's border colour for this kind.
  final String barColor;

  /// The body tint, GitHub's background colour for this kind.
  final String backgroundColor;

  const AlertKind({
    required this.type,
    required this.label,
    required this.emoji,
    required this.barColor,
    required this.backgroundColor,
  });
}

const List<AlertKind> alertKinds = [
  AlertKind(
    type: 'note',
    label: 'Заметка',
    emoji: '📝',
    barColor: '#0969da',
    backgroundColor: '#ddf4ff',
  ),
  AlertKind(
    type: 'tip',
    label: 'Совет',
    emoji: '💡',
    barColor: '#1a7f37',
    backgroundColor: '#dafbe1',
  ),
  AlertKind(
    type: 'important',
    label: 'Важно',
    emoji: '❗',
    barColor: '#8250df',
    backgroundColor: '#fbefff',
  ),
  AlertKind(
    type: 'warning',
    label: 'Внимание',
    emoji: '⚠️',
    barColor: '#d4a72c',
    backgroundColor: '#fff8c5',
  ),
  AlertKind(
    type: 'caution',
    label: 'Осторожно',
    emoji: '⛔',
    barColor: '#cf222e',
    backgroundColor: '#ffebe9',
  ),
];

/// Rewrites the `<div class="markdown-alert">` that `AlertBlockSyntax` produces
/// into HTML that survives stepik.org.
///
/// Neither `div` nor GitHub's classes are on the whitelist, and Stepik ships no
/// CSS for them, so the alert has to carry its own appearance. Of the CSS
/// properties tried against the real editor only `background-color` and `width`
/// are kept — `border-left` and `padding` are dropped — so the accent bar is a
/// narrow tinted cell rather than a border, and the gutter is a cell rather than
/// padding:
///
/// ```html
/// <table border="0" cellpadding="0" cellspacing="0" style="width:100%">
///   <tbody><tr>
///     <td style="background-color:#d4a72c; width:4px">&nbsp;</td>
///     <td style="width:12px">&nbsp;</td>
///     <td style="background-color:#fff8c5"> ... </td>
///   </tr></tbody>
/// </table>
/// ```
///
/// Declaration order matches what the editor writes back on save (properties
/// alphabetised, `; ` separated, no trailing `;`), so a step round-tripped
/// through Stepik comes back byte-identical.
class AlertTransformer extends NodeTransformer {
  static const String _classPrefix = 'markdown-alert-';
  static const String _barWidth = '4px';
  static const String _gutterWidth = '12px';

  static final Map<String, AlertKind> _byType = {
    for (final kind in alertKinds) kind.type: kind,
  };

  const AlertTransformer();

  @override
  List<Node> apply(
    Element element, {
    required bool isFirstNode,
    required bool isTopLevel,
  }) {
    if (element.tag != 'div') return [element];

    final kind = _kindOf(element.attributes['class']);
    if (kind == null) return [element];

    // The title paragraph is rebuilt rather than reused: by the time this runs
    // its text has already been through the text transformers.
    final body = element.children?.where(_isNotTitle).toList() ?? <Node>[];

    return [
      Element('table', [
          Element('tbody', [
            Element('tr', [
              _cell(
                'background-color:${kind.barColor}; width:$_barWidth',
                [Text('&nbsp;')],
              ),
              _cell('width:$_gutterWidth', [Text('&nbsp;')]),
              _cell('background-color:${kind.backgroundColor}', [
                Element('p', [
                  Element('strong', [Text('${kind.emoji} ${kind.label}')]),
                ]),
                ...body,
              ]),
            ]),
          ]),
        ])
        ..attributes.addAll({
          'border': '0',
          'cellpadding': '0',
          'cellspacing': '0',
          'style': 'width:100%',
        }),
    ];
  }

  AlertKind? _kindOf(String? classes) {
    if (classes == null) return null;
    for (final name in classes.split(' ')) {
      if (name.startsWith(_classPrefix)) {
        return _byType[name.substring(_classPrefix.length)];
      }
    }
    return null;
  }

  bool _isNotTitle(Node node) =>
      node is! Element || node.attributes['class'] != 'markdown-alert-title';

  Element _cell(String style, List<Node> children) =>
      Element('td', children)..attributes['style'] = style;
}
