import 'package:markdown/markdown.dart';
import 'package:pluto/domain/abbreviations.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/domain/html_whitelist.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/markdown/abbreviation_transformer.dart';
import 'package:pluto/markdown/auto_emphasize_transformer.dart';
import 'package:pluto/markdown/config_link_transformer.dart';
import 'package:pluto/markdown/config_syntax.dart';
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

  /// Expands `{{config.<key>}}` references. Without it they are left as written.
  final CourseConfig? config;

  /// Marks the first use of each declared acronym with `<abbr>`. Without it no
  /// text is marked.
  final Abbreviations? abbreviations;

  const StepikMarkdownRenderer({this.links, this.config, this.abbreviations});

  /// Ordered styling rules applied to the parsed AST before rendering.
  List<NodeTransformer> get _transformers => [
    const TagRewriteTransformer(tagRewrites),
    const CenteredHeadingTransformer(),
    // Before [RefLinkTransformer], so a config value may supply part of a `ref:`
    // target and still resolve.
    ConfigLinkTransformer(config),
    RefLinkTransformer(links),
  ];

  /// Rules applied to [Text] leaves, unless inside [_noWrapTags].
  ///
  /// Built per render: [AbbreviationTransformer] tracks which terms it has
  /// already marked, and "first use" means first in the step being rendered.
  List<TextTransformer> _buildTextTransformers() => [
    // Before [AutoItalicTransformer], which would otherwise wrap an
    // abbreviation in `<em>` and hide it: the fold in [_transform] only
    // re-applies later transformers to nodes that are still [Text].
    AbbreviationTransformer(abbreviations ?? Abbreviations.empty),
    const AutoItalicTransformer(),
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

  /// Built per render rather than shared: [ConfigInlineSyntax] carries the
  /// course's own [config].
  ExtensionSet get _extensionSet => ExtensionSet(
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
      ConfigInlineSyntax(config),
      MarkerInlineSyntax(),
      InlineHtmlSyntax(),
      StrikethroughSyntax(),
      EmojiSyntax(),
      ColorSwatchSyntax(),
      AutolinkExtensionSyntax(),
    ]),
  );

  String render(String markdown) {
    final document = Document(extensionSet: _extensionSet);
    final nodes = document.parse(markdown);
    final textTransformers = _buildTextTransformers();

    final rewritten = <Node>[
      for (final (index, node) in nodes.indexed)
        ..._transform(
          node,
          isFirstNode: index == 0,
          isTopLevel: true,
          insideNoWrap: false,
          textTransformers: textTransformers,
        ),
    ];
    return '${renderToHtml(rewritten)}\n';
  }

  List<Node> _transform(
    Node node, {
    required bool isFirstNode,
    required bool isTopLevel,
    required bool insideNoWrap,
    required List<TextTransformer> textTransformers,
  }) {
    if (node is Text) {
      if (insideNoWrap) return [node];
      return textTransformers.fold(
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
      textTransformers: textTransformers,
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
