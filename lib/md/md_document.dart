import 'package:pluto/md/front_matter.dart';

/// A source file as the formats see it: a front-matter block and the text
/// below it.
///
/// This is the layer that owns the `---` markers and YAML quoting, so the five
/// entity formats only have to map their fields and can never disagree about
/// how a file is framed.
class MdDocument {
  final FrontMatter frontMatter;

  /// Everything after the closing `---`, verbatim.
  final String body;

  const MdDocument({required this.frontMatter, required this.body});

  static const MdDocument empty = MdDocument(
    frontMatter: FrontMatter.empty,
    body: '',
  );

  static MdDocument parse(String source) {
    final (frontMatter, body) = FrontMatter.split(source);
    return MdDocument(frontMatter: frontMatter, body: body);
  }

  /// The file's full text with [fields] applied to the front matter.
  ///
  /// [body] defaults to the one parsed in, so a format that owns only front
  /// matter — a section, a unit, a lesson — keeps whatever an author wrote
  /// below it.
  String write(Map<String, Object?> fields, {String? body}) {
    return '${frontMatter.write(fields)}${body ?? this.body}';
  }
}
