import 'package:markdown/markdown.dart';

/// Transforms a single Markdown AST [Element] into its replacement node(s).
abstract class NodeTransformer {
  const NodeTransformer();

  List<Node> apply(Element element, {required bool isFirstNode});
}

/// Transforms a single Markdown AST [Text] leaf into its replacement node(s),
/// e.g. splitting text and wrapping parts in inline elements.
abstract class TextTransformer {
  const TextTransformer();

  List<Node> apply(Text text);
}

/// Renames tags according to [rewrites] (e.g. `del` -> `strike`), preserving
/// children, attributes and generated id.
class TagRewriteTransformer extends NodeTransformer {
  final Map<String, String> rewrites;

  const TagRewriteTransformer(this.rewrites);

  @override
  List<Node> apply(Element element, {required bool isFirstNode}) {
    final tag = rewrites[element.tag];
    if (tag == null) return [element];
    return [
      Element(tag, element.children)
        ..attributes.addAll(element.attributes)
        ..generatedId = element.generatedId,
    ];
  }
}

/// Centers headings and appends an empty paragraph after them, so a title is
/// always centered and keeps a line of spacing before the following content.
///
/// Produces e.g. `<h1 style="text-align:center">Title</h1><p>&nbsp;</p>` for first h1 node.
/// Produces `<p>&nbsp;</p><h1>Title</h1>` for other header nodes.
class CenteredHeadingTransformer extends NodeTransformer {
  final Set<String> tags;

  const CenteredHeadingTransformer({this.tags = const {'h1', 'h2', 'h3'}});

  @override
  List<Node> apply(Element element, {required bool isFirstNode}) {
    if (!tags.contains(element.tag)) return [element];

    if (isFirstNode) {
      element.attributes['style'] = 'text-align:center';
      return [element, Element('p', <Node>[Text('&nbsp;')])];
    }

    return [Element('p', <Node>[Text('&nbsp;')]), element];
  }
}
