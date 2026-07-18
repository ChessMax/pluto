/// Declarative whitelist of the HTML that stepik.org accepts. See https://help.stepik.org/article/54794
class TagRule {
  final Set<String> attributes;
  final Set<String> urlAttributes;

  const TagRule({
    this.attributes = const {},
    this.urlAttributes = const {},
  });
}

const Set<String> globalAttributes = {};
const Set<String> allowedUrlSchemes = {'http', 'https', 'mailto'};

/// The stepik.org HTML whitelist, keyed by lower-case tag name.
///
/// A tag absent from this map is not allowed. An attribute absent from a tag's
/// [TagRule] (and from [globalAttributes]) is not allowed on that tag.
const Map<String, TagRule> allowedTags = {
  'a': TagRule(
    attributes: {'title', 'rel', 'target'},
    urlAttributes: {'href'},
  ),
  'abbr': TagRule(attributes: {'title'}),
  'strong': TagRule(),
  'audio': TagRule(
    attributes: {'controls'},
    urlAttributes: {'src'},
  ),
  'b': TagRule(),
  'blockquote': TagRule(),
  'br': TagRule(),
  'code': TagRule(),
  'pre': TagRule(),
  'em': TagRule(),
  'h1': TagRule(),
  'h2': TagRule(),
  'h3': TagRule(),
  'i': TagRule(),
  'iframe': TagRule(
    attributes: {'width', 'height', 'sandbox', 'scrolling'},
    urlAttributes: {'src'},
  ),
  'img': TagRule(
    attributes: {'alt', 'title', 'width', 'height'},
    urlAttributes: {'src'},
  ),
  'li': TagRule(),
  'ol': TagRule(),
  'ul': TagRule(),
  'p': TagRule(),
  'span': TagRule(),
  'strike': TagRule(),
  'details': TagRule(),
  'summary': TagRule(),
  'table': TagRule(
    attributes: {'border', 'cellpadding', 'cellspacing', 'style'},
  ),
  'thead': TagRule(),
  'tbody': TagRule(),
  'tr': TagRule(),
  'th': TagRule(),
  'td': TagRule(attributes: {'style'}),
};
