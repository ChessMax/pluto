import 'package:markdown/markdown.dart';
import 'package:pluto/domain/html_whitelist.dart';

/// Renders Markdown to HTML constrained by the Stepik tags whitelist.
///
/// See also [allowedTags] and [tagRewrites].
class StepikMarkdownRenderer {
  const StepikMarkdownRenderer();

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
    final rewritten = nodes.map(_rewrite).toList();
    return '${renderToHtml(rewritten)}\n';
  }

  Node _rewrite(Node node) {
    if (node is! Element) return node;
    final children = node.children?.map(_rewrite).toList();
    final tag = tagRewrites[node.tag] ?? node.tag;
    return Element(tag, children)
      ..attributes.addAll(node.attributes)
      ..generatedId = node.generatedId;
  }
}
