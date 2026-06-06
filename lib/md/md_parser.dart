import 'package:pluto/md/md_file.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:yaml/yaml.dart';

class MdParser {
  const MdParser();

  MdFile parse(SourceView2 source2) {
    if (source2.isEmpty) {
      return const MdFile(
        frontMatter: <String, dynamic>{},
        blocks: [],
        content: '',
      );
    }

    String? readText() {
      final start = source2.position;
      source2.readUntilAny(const ['---', '```']);
      final end = source2.position;
      if (start < end) {
        final text = source2.substring(-end + start, 0);
        return text;
      }
      return null;
    }

    dynamic readFrontMatter() {
      if (source2.readString('---\n') != null) {
        final text = readText();
        if (text == null) {
          throw 'Expected front matter not found';
        }
        if (source2.readString('---\n') == null) {
          throw 'Expected front matter end not found';
        }
        return loadYaml(text);
      }

      return null;
    }

    MdCodeBlock? tryReadCodeBlock() {
      if (source2.readString('```') != null) {
        final lang = source2.readIdentifier();
        source2.readChar('\n');

        final content = readText();

        if (content == null) {
          throw 'Expected code content not found';
        }
        if (source2.readString('```') == null) {
          throw 'Expected front matter end not found';
        }
        source2.readChar('\n');
        return MdCodeBlock(lang, content);
      }
      return null;
    }

    final tags = <Tag>[];
    final blocks = <Tag>[];
    final codes = <MdCodeBlock>[];
    final frontMatter = readFrontMatter();

    final content = readText();

    loop:
    do {
      final codeBlock = tryReadCodeBlock();
      if (codeBlock != null) {
        codes.add(codeBlock);
        continue;
      }

      // TODO: could tags parsing be reused?
      final str = source2.readChar('<');
      switch (str) {
        case '<':
          final tag = source2.readTag();
          if (tag != null) {
            blocks.add(tag);
            if (tag.type == .opening) {
              tags.add(tag);
            } else if (tag.type == .closing) {
              if (tags.isEmpty) throw 'Unexpected closing tag: ${tag.name}';
              if (tags.last.name != tag.name) {
                throw 'Unbalanced tags closing: ${tags.last.name} and ${tag.name}';
              } else {
                tags.removeLast();
                // if (!topLevel) {
                //   break loop;
                // } else {
                continue loop;
                // }
              }
            }
            continue loop;
          }
          break;
        case null:
          break loop;
        default:
          throw 'Unexpected branch ($str)';
      }
    } while (!source2.isEmpty);

    // final content = source2.isEmpty ? '' : source2.substring(0);
    if (!source2.isEmpty) throw 'Content is not empty: ${source2.toString()}';
    print('MdText lexer end: ${source2.toString()}');
    return MdFile(
      frontMatter: frontMatter ?? <String, dynamic>{},
      codes: codes,
      blocks: blocks,
      content: content ?? '',
    );
  }
}

// TODO: make global and reuse
extension on String {
  bool operator <=(String other) => codeUnitAt(0) <= other.codeUnitAt(0);

  bool operator >=(String other) => codeUnitAt(0) >= other.codeUnitAt(0);

  bool get isDigit => this >= '0' && this <= '9';

  bool get isAlpha => this >= 'a' && this <= 'z' || this >= 'A' && this <= 'Z';

  bool get isIdentifierStart => isAlpha || this == '_' || this == '\$';

  bool get isIdentifierContinue => isIdentifierStart || isDigit;

  bool get isWhiteSpace =>
      this == ' ' || this == '\n' || this == '\t' || this == '\r';
}
