/// A fenced code block, with the span it occupies in [MdFile.content] so a
/// reader that consumes the block can cut it back out of the body.
class MdCodeBlock {
  final String? lang;
  final String content;

  /// Offsets into [MdFile.content], covering the opening fence line through the
  /// closing one.
  final int start;
  final int end;

  const MdCodeBlock({
    required this.lang,
    required this.content,
    required this.start,
    required this.end,
  });
}

/// A parsed course `.md` file: its front matter, its body, and the fenced code
/// blocks found in that body.
class MdFile {
  final dynamic frontMatter;

  /// The body exactly as written, fences included. Whether a fence is part of a
  /// step's text or configuration for it depends on the step type, which the
  /// parser does not know — so removing one is [contentWithout]'s job.
  final String content;

  final List<MdCodeBlock> codes;

  const MdFile({
    required this.frontMatter,
    required this.content,
    this.codes = const [],
  });

  /// The first block written in [lang], or null when the body has none.
  MdCodeBlock? getCode(String lang) {
    for (final code in codes) {
      if (code.lang == lang) return code;
    }

    return null;
  }

  String? getCodeContent(String lang) => getCode(lang)?.content;

  /// [content] with [blocks] cut out of it — what a reader that has already
  /// consumed those blocks should treat as the body's text.
  String contentWithout(Iterable<MdCodeBlock> blocks) {
    final spans = blocks.toList()..sort((a, b) => a.start.compareTo(b.start));

    final sb = StringBuffer();
    var at = 0;
    for (final span in spans) {
      sb.write(content.substring(at, span.start));
      at = span.end;
    }
    sb.write(content.substring(at));

    return sb.toString();
  }
}
