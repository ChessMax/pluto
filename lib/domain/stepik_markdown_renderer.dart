import 'package:markdown/markdown.dart';
import 'package:pluto/domain/html_whitelist.dart';

/// Renders Markdown to HTML constrained by the Stepik whitelist.
///
/// See also [allowedTags] and [tagRewrites].
class StepikMarkdownRenderer {
  const StepikMarkdownRenderer();

  String render(String markdown) {
    final document = Document(extensionSet: ExtensionSet.gitHubWeb);
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
