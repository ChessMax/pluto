import 'package:markdown/markdown.dart';
import 'package:pluto/domain/link_index.dart';
import 'package:pluto/markdown/node_transformer.dart';

/// Rewrites in-course links — `[text](ref:section_01/unit_01/step_02)` — to the
/// Stepik URL of the step they point at.
///
/// An unresolvable ref is left alone rather than dropped or guessed at: `ref:`
/// is not an allowed URL scheme, so validation reports it against the step it
/// was written in instead of a broken link reaching students.
class RefLinkTransformer extends NodeTransformer {
  final LinkIndex? links;

  const RefLinkTransformer(this.links);

  @override
  List<Node> apply(Element element, {required bool isFirstNode}) {
    if (element.tag != 'a') return [element];

    final href = element.attributes['href'];
    if (href == null || !href.startsWith('$refScheme:')) return [element];

    final target = links?.resolve(href.substring(refScheme.length + 1));
    if (target == null) return [element];

    element.attributes['href'] = target.url;
    return [element];
  }
}
