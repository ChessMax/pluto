import 'package:markdown/markdown.dart';
import 'package:pluto/domain/course_config.dart';
import 'package:pluto/markdown/node_transformer.dart';

/// Expands `{{config.<key>}}` inside URL attributes, e.g.
/// `[write us](mailto:{{config.support_email}})`.
///
/// A link destination is parsed into an attribute before inline syntaxes run, so
/// it never becomes a [Text] node and [ConfigInlineSyntax] cannot see it. This
/// covers the case config variables are most wanted for.
class ConfigLinkTransformer extends NodeTransformer {
  static const List<String> _urlAttributes = ['href', 'src'];

  final CourseConfig? config;

  const ConfigLinkTransformer(this.config);

  @override
  List<Node> apply(
    Element element, {
    required bool isFirstNode,
    required bool isTopLevel,
  }) {
    for (final name in _urlAttributes) {
      final value = element.attributes[name];
      if (value == null) continue;
      element.attributes[name] = substituteConfigInUrl(value, config);
    }

    return [element];
  }
}
