import 'package:markdown/markdown.dart';
import 'package:pluto/domain/html_whitelist.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/markdown/auto_emphasize_transformer.dart';
import 'package:pluto/markdown/node_transformer.dart';
import 'package:pluto/markdown/marker_syntax.dart';
import 'package:pluto/markdown/ref_link_transformer.dart';

/// Renders Markdown to HTML constrained by the Stepik tags whitelist.
///
/// See also [allowedTags] and [_transformers].
class StepikMarkdownRenderer {
  /// Resolves `ref:` links to other steps. Without it such links are left as
  /// written, for validation to report.
  final LinkIndex? links;

  const StepikMarkdownRenderer({this.links});

  /// Ordered styling rules applied to the parsed AST before rendering.
  List<NodeTransformer> get _transformers => [
    const TagRewriteTransformer(tagRewrites),
    const CenteredHeadingTransformer(),
    RefLinkTransformer(links),
  ];

  /// Rules applied to [Text] leaves, unless inside [_noWrapTags].
  static const List<TextTransformer> _textTransformers = [
    AutoItalicTransformer(),
  ];

  /// Tags whose text content must not be auto-wrapped: code (literal) and
  /// already-emphasized text.
  static const Set<String> _noWrapTags = {
    'code',
    'pre',
    'em',
    'i',
    'strong',
    'b',
  };

  static final gitHubWeb = ExtensionSet(
    List<BlockSyntax>.unmodifiable(<BlockSyntax>[
      const FencedCodeBlockSyntax(),
      // const HeaderWithIdSyntax(),
      const SetextHeaderWithIdSyntax(),
      const TableSyntax(),
      const UnorderedListWithCheckboxSyntax(),
      const OrderedListWithCheckboxSyntax(),
      const FootnoteDefSyntax(),
      const AlertBlockSyntax(),
    ]),
    List<InlineSyntax>.unmodifiable(<InlineSyntax>[
      MarkerInlineSyntax(),
      InlineHtmlSyntax(),
      StrikethroughSyntax(),
      EmojiSyntax(),
      ColorSwatchSyntax(),
      AutolinkExtensionSyntax(),
    ]),
  );

  String render(String markdown) {
    final document = Document(extensionSet: gitHubWeb);
    final nodes = document.parse(markdown);

    final rewritten = <Node>[
      for (final (index, node) in nodes.indexed)
        ..._transform(
          node,
          isFirstNode: index == 0,
          isTopLevel: true,
          insideNoWrap: false,
        ),
    ];
    return '${renderToHtml(rewritten)}\n';
  }

  List<Node> _transform(
    Node node, {
    required bool isFirstNode,
    required bool isTopLevel,
    required bool insideNoWrap,
  }) {
    if (node is Text) {
      if (insideNoWrap) return [node];
      return _textTransformers.fold(
        <Node>[node],
        (acc, transformer) => [
          for (final n in acc)
            if (n is Text) ...transformer.apply(n) else n,
        ],
      );
    }

    if (node is! Element) return [node];

    final childInsideNoWrap = insideNoWrap || _noWrapTags.contains(node.tag);
    List<Node> transform(Node node) => _transform(
      node,
      isFirstNode: false,
      isTopLevel: false,
      insideNoWrap: childInsideNoWrap,
    );

    final children = node.children?.expand(transform).toList();
    final rebuilt = Element(node.tag, children)
      ..attributes.addAll(node.attributes)
      ..generatedId = node.generatedId;

    var result = <Node>[rebuilt];
    for (final transformer in _transformers) {
      result = [
        for (final n in result)
          if (n is Element)
            ...transformer.apply(
              n,
              isFirstNode: isFirstNode,
              isTopLevel: isTopLevel,
            )
          else
            n,
      ];
    }
    return result;
  }
}
