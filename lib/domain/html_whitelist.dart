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

// TODO: it would be nice if we could use strike tag from allowedTags table somehow.
// In that case we would some have compile time safety
const Map<String, String> tagRewrites = {'del': 'strike'};

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
  // `class` departs from Stepik's documented whitelist, but its own lesson
  // editor emits `<pre><code class="language-dart">` for a code block — and the
  // markdown package renders a fenced block the same way, so rejecting it would
  // block every step containing code.
  'code': TagRule(attributes: {'class'}),
  'pre': TagRule(),
  'em': TagRule(),
  'h1': TagRule(attributes: {'style'}),
  'h2': TagRule(attributes: {'style'}),
  'h3': TagRule(attributes: {'style'}),
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
  'p': TagRule(attributes: {'style'}),
  // `style` departs from Stepik's documented whitelist; enabled so inline
  // `[[TODO: ...]]` markers can render as a coloured span. See marker_syntax.dart.
  'span': TagRule(attributes: {'style'}),
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
