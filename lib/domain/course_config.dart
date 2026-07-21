/// Namespace an author writes in front of a config key, e.g.
/// `{{config.support_email}}`.
///
/// Qualifying the reference — rather than prefixing every key with `config_` —
/// keeps the YAML clean and leaves room for other namespaces later.
const String configNamespace = 'config';

/// Matches a `{{config.<key>}}` reference, capturing the key.
final String configPattern =
    r'\{\{\s*' + configNamespace + r'\.([A-Za-z_][A-Za-z0-9_]*)\s*\}\}';

/// Values declared once in `course.md` front matter and referenced from step
/// Markdown, so changing e.g. a support address is a one-line edit.
///
/// ```yaml
/// config:
///   support_email: help@example.com
/// ```
class CourseConfig {
  final Map<String, String> values;

  const CourseConfig(this.values);

  static const CourseConfig empty = CourseConfig(<String, String>{});

  bool get isEmpty => values.isEmpty;
  bool get isNotEmpty => values.isNotEmpty;

  String? resolve(String key) => values[key];

  /// Reads the `config:` map of parsed front matter.
  ///
  /// Scalars are stringified so `year: 2026` need not be quoted; a null value is
  /// dropped rather than rendered as the text "null". Nested maps and lists are
  /// rejected: a reference expands to inline text, so there is nothing sensible
  /// to substitute for them.
  static CourseConfig fromYaml(dynamic node) {
    if (node == null) return empty;
    if (node is! Map) {
      throw 'course.md: `config` must be a map of key/value pairs';
    }

    final values = <String, String>{};
    for (final entry in node.entries) {
      final key = entry.key.toString();
      if (!_keyPattern.hasMatch(key)) {
        throw 'course.md: invalid config key `$key` '
            '(letters, digits and underscore only, not starting with a digit)';
      }

      final value = entry.value;
      switch (value) {
        case null:
          continue;
        case Map() || Iterable():
          throw 'course.md: config value `$key` must be a scalar';
        default:
          values[key] = value.toString();
      }
    }

    return CourseConfig(values);
  }

  static final RegExp _keyPattern = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');
}

/// Replaces every resolvable `{{config.<key>}}` in [input].
///
/// An unknown key is left exactly as written rather than blanked: a visible
/// `{{config.support_email}}` is a typo an author can see and validation can
/// report, whereas a silently empty support address is not.
String substituteConfig(String input, CourseConfig? config) {
  if (config == null || config.isEmpty) return input;

  return input.replaceAllMapped(_referencePattern, (match) {
    return config.resolve(match.group(1)!) ?? match.group(0)!;
  });
}

/// Replaces every resolvable reference in a link destination.
///
/// A destination is percent-encoded by the Markdown parser before any transformer
/// sees it — `{{config.x}}` arrives as `%7B%7Bconfig.x%7D%7D` — so the encoded
/// spelling has to be matched too. Note that the parser only recognises a
/// destination without spaces, so `{{ config.x }}` is not a link at all; that is
/// the author's error to see, and it is left alone here.
String substituteConfigInUrl(String input, CourseConfig? config) {
  if (config == null || config.isEmpty) return input;

  return substituteConfig(input, config).replaceAllMapped(
    _encodedReferencePattern,
    (match) => config.resolve(match.group(1)!) ?? match.group(0)!,
  );
}

/// Every `{{config.<key>}}` in [input] naming a key [config] does not define.
List<String> unknownConfigKeys(String input, CourseConfig? config) {
  return [
    for (final match in _referencePattern.allMatches(input))
      if (config?.resolve(match.group(1)!) == null) match.group(1)!,
  ];
}

final RegExp _referencePattern = RegExp(configPattern);

/// [configPattern] as it survives percent-encoding of a link destination.
final RegExp _encodedReferencePattern = RegExp(
  '%7B%7B\\s*$configNamespace\\.([A-Za-z_][A-Za-z0-9_]*)\\s*%7D%7D',
  caseSensitive: false,
);
