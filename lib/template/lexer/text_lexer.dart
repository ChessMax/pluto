import 'package:pluto/extensions/string_extensions.dart';
import 'package:pluto/template/lexer/explicit_expression_lexer.dart';
import 'package:pluto/template/lexer/if_statement_lexer.dart';
import 'package:pluto/template/lexer/implicit_expression_lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/statement_lexer.dart';
import 'package:pluto/template/token.dart';

class TextLexer {
  final bool topLevel;

  const TextLexer({required this.topLevel});

  Iterable<Token> tokenize(SourceView source) sync* {

    if (source.isEmpty) {
      yield Token(type: .text, value: '');
      return;
    }

    String? readText() {
      final text = source.readWhile(
        (source) => switch (source.peak()) {
          // <!--
          '<' when source.peakNext() == '!' => 1,
          '<' || '}' => 0,
          '@' when source.peakNext() == '@' => 0,
          '@' when source.peakNext() == 'i' && source.peakNextNext() == 'f' =>
            0,
          '@' => 0,
          _ => 1,
        },
      );
      return text;
    }

    final tags = <Tag>[];

    loop:
    do {
      final text = readText();
      if (text != null) {
        yield Token(type: .text, value: text);
      }

      final str = source.readAny(const ['<', '@@', '@{', '@(', '@if', '@', '}']);
      switch (str) {
        case '}':
          yield Token(type: .blockEnd);
          break;
        case '<':
          final tag = source.readTag();
          if (tag != null) {
            yield Token(
              type: tag.type == .opening ? .openTag : .closingTag,
              value: tag,
            );
            if (tag.type == .opening) {
              tags.add(tag);
            } else if (tag.type == .closing) {
              if (tags.isEmpty) throw 'Unexpected closing tag: ${tag.name}';
              if (tags.last.name != tag.name) {
                throw 'Unbalanced tags closing: ${tags.last.name} and ${tag.name}';
              } else {
                tags.removeLast();
                if (!topLevel) {
                  break loop;
                } else {
                  continue loop;
                }
              }
            }
            continue loop;
          }
          break;
        case '@@':
          yield Token(type: .text, value: '@');
          continue loop;
        case '@{':
          yield Token(type: .blockStart);
          yield* const StatementLexer().tokenize(source);
          continue loop;
        case '@(':
          source.position -= 1;
          yield* const ExplicitExpressionLexer().tokenize(source);
          continue loop;
        case '@if':
          yield Token(type: .ifStmt);
          yield* const IfStatementLexer().tokenize(source);
          break;
        case '@':
          if (source.peakNext()?.isIdentifierStart != true) {
            throw 'Expected implicit expression';
          }
          yield* const ImplicitExpressionLexer().tokenize(source);
          continue loop;
        case null:
          break loop;
        default:
          throw 'Unexpected branch ($str)';
      }
      // source.position++;
    } while (source.isNotEmpty);

    if (source.isNotEmpty) {
      if (!topLevel && tags.isEmpty) {
        print('Text lexer end: ${source.toString()}');
        return;
      }
      yield Token(type: .text, value: source.substring(0 ));
    }
    print('Text lexer end: ${source.toString()}');
  }
}
