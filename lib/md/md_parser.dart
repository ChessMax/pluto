import 'package:pluto/md/md_file.dart';
import 'package:yaml/yaml.dart';

/// A source line, with the offsets that bound it. [end] is the start of the
/// next line, so a span built from two lines includes the newline between them.
typedef _Line = ({String text, int start, int end});

/// Parses a course `.md` file into front matter, body and fenced code blocks.
///
/// Both delimiters are line-anchored: `---` and ` ``` ` mark structure only at
/// the start of a line. An author writing `---` mid-sentence, as a thematic
/// break's neighbour or in a table separator is writing prose, and a fence
/// indented under a list item belongs to that item rather than to the file.
class MdParser {
  static final RegExp _frontMatterFence = RegExp(r'^---[ \t]*\r?$');
  static final RegExp _openFence = RegExp(r'^```([A-Za-z0-9_+-]*)[ \t]*\r?$');
  static final RegExp _closeFence = RegExp(r'^```[ \t]*\r?$');

  const MdParser();

  MdFile parse(String source) {
    final lines = _split(source);

    var index = 0;
    dynamic frontMatter = <String, dynamic>{};

    if (lines.isNotEmpty && _frontMatterFence.hasMatch(lines.first.text)) {
      final end = lines.indexWhere(
        (line) => _frontMatterFence.hasMatch(line.text),
        1,
      );
      if (end == -1) throw 'Expected front matter end not found';

      frontMatter =
          loadYaml(source.substring(lines[1].start, lines[end].start)) ??
          <String, dynamic>{};
      index = end + 1;
    }

    // The body keeps its own offsets, so a block's span can be applied to it
    // without the caller knowing where the front matter ended.
    final contentStart = index < lines.length
        ? lines[index].start
        : source.length;

    final codes = <MdCodeBlock>[];
    for (var i = index; i < lines.length; i++) {
      final open = _openFence.firstMatch(lines[i].text);
      if (open == null) continue;

      final close = lines.indexWhere(
        (line) => _closeFence.hasMatch(line.text),
        i + 1,
      );
      if (close == -1) throw 'Expected code fence end not found';

      final lang = open.group(1);
      codes.add(
        MdCodeBlock(
          lang: lang == null || lang.isEmpty ? null : lang,
          content: source.substring(lines[i].end, lines[close].start),
          start: lines[i].start - contentStart,
          end: lines[close].end - contentStart,
        ),
      );

      i = close;
    }

    return MdFile(
      frontMatter: frontMatter,
      content: source.substring(contentStart),
      codes: codes,
    );
  }

  static List<_Line> _split(String source) {
    final lines = <_Line>[];

    var start = 0;
    while (start <= source.length) {
      final br = source.indexOf('\n', start);
      if (br == -1) {
        if (start < source.length) {
          lines.add((
            text: source.substring(start),
            start: start,
            end: source.length,
          ));
        }
        break;
      }

      lines.add((
        text: source.substring(start, br),
        start: start,
        end: br + 1,
      ));
      start = br + 1;
    }

    return lines;
  }
}
