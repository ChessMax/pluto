import 'package:markdown/markdown.dart';
import 'package:pluto/domain/html_whitelist.dart';
import 'package:pluto/markdown/node_transformer.dart';

/// Renders Markdown to HTML constrained by the Stepik tags whitelist.
///
/// See also [allowedTags] and [_transformers].
class StepikMarkdownRenderer {
  const StepikMarkdownRenderer();

  /// Ordered styling rules applied to the parsed AST before rendering.
  static const List<NodeTransformer> _transformers = [
    TagRewriteTransformer(tagRewrites),
    CenteredHeadingTransformer(),
  ];

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

    List<Node> transform(Node node) => _transform(nodes, node);

    final rewritten = nodes.expand(transform).toList();
    return '${renderToHtml(rewritten)}\n';
  }

  List<Node> _transform(List<Node> nodes, Node node) {
    if (node is! Element) return [node];

    List<Node> transform(Node node) => _transform(nodes, node);

    final isFirstNode = nodes.firstOrNull == node;

    final children = node.children?.expand(transform).toList();
    final rebuilt = Element(node.tag, children)
      ..attributes.addAll(node.attributes)
      ..generatedId = node.generatedId;

    var result = <Node>[rebuilt];
    for (final transformer in _transformers) {
      result = [
        for (final n in result)
          if (n is Element) ...transformer.apply(n, isFirstNode: isFirstNode) else n,
      ];
    }
    return result;
  }
}
