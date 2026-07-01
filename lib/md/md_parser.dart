import 'package:pluto/md/md_file.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:yaml/yaml.dart';

class MdParser {
  const MdParser();

  MdFile parse(SourceView source) {
    if (source.isEmpty) {
      return const MdFile(
        frontMatter: <String, dynamic>{},
        blocks: [],
        content: '',
      );
    }

    String? readText() {
      final start = source.position;
      if (source.readUntilAny(const ['---', '```']) != null) {
        final end = source.position;
        if (start < end) {
          final text = source.substring(-end + start, 0);
          return text;
        }
      } else {
        return source.consumeRest();
      }

      return null;
    }

    dynamic readFrontMatter() {
      if (source.readString('---\n') != null) {
        final text = readText();
        if (text == null) {
          throw 'Expected front matter not found';
        }
        if (source.readString('---\n') == null) {
          throw 'Expected front matter end not found';
        }
        return loadYaml(text);
      }

      return null;
    }

    MdCodeBlock? tryReadCodeBlock() {
      if (source.readString('```') != null) {
        final lang = source.readIdentifier();
        source.readChar('\n');

        final content = readText();

        if (content == null) {
          throw 'Expected code content not found';
        }
        if (source.readString('```') == null) {
          throw 'Expected front matter end not found';
        }
        source.readChar('\n'); // TODO: consume all ws?
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
      final str = source.readChar('<');
      switch (str) {
        case '<':
          final tag = source.readTag();
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
    } while (source.isNotEmpty);

    // final content = source.isEmpty ? '' : source2.substring(0);
    if (source.isNotEmpty) throw 'Content is not empty: ${source.toString()}';
    print('MdText lexer end: ${source.toString()}');
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
