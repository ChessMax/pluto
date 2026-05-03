import 'package:pluto/template/lexer/explicit_expression_lexer.dart';
import 'package:pluto/template/lexer/implicit_expression_lexer.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/statement_lexer.dart';
import 'package:pluto/template/token.dart';

class TextLexer {
  final bool topLevel;

  const TextLexer({required this.topLevel});

  Iterable<Token> tokenize(SourceView source) sync* {
    print('Text lexer begin ($topLevel): ${source.toString()}');
    var position = 0;

    if (source.isEmpty) {
      yield Token(type: .text, value: '');
      print('Text lexer end: ${source.toString()}');
      return;
    }

    final tags = <Token>[];

    Iterable<Token> consumeText() sync* {
      if (position > 0) {
        yield Token(type: .text, value: source.substring(0, position));
        source.consume(position);
      }
    }

    Token? tryReadTag(SourceView source, int position) {
      var start = position;
      var closing = false;

      if (source.peakNext(position) == '/') {
        ++position;
        closing = true;
      }

      if (position < source.length) {
        while (++position < source.length && source[position].isIdentifierContinue) {}
        if (position < source.length && source[position] == '>') {
          final tag = source.substring(start + (closing ? 1 : 0), position);
          return Token(type: closing ? .closingTag : .openTag, value: tag);
        }
      }

      return null;
    }

    loop:
    do {
      final char = source[position];
      swt:
      switch (char) {
        case '<':
          final tag = tryReadTag(source, position + 1);
          if (tag != null) {
            yield* consumeText();
            yield tag;
            source.consume(tag.text.length + (tag.type == .closingTag ? 3 : 2));
            position = 0;
            if (tag.type == .openTag) {
              tags.add(tag);
            } else if (tags.isEmpty) {
              throw 'Unexpected closing tag: ${tag.text}';
            } else if (tags.last.value != tag.value) {
              throw 'Unbalanced tags closing: ${tags.last.value} and ${tag.value}';
            } else {
              tags.removeLast();
            }
          }
          continue loop; // TODO: hangs if only <?
        case '@':
          final nextChar = source.peakNext(position + 1);
          switch (nextChar) {
            case '@':
              consumeText();
              source.consume();
              yield Token(type: .text, value: '@');
              source.consume();
              position = 0;
              break swt;
            case '{':
              yield* consumeText();
              yield Token(type: .blockStart);
              source.consume(2);
              yield* const StatementLexer().tokenize(source);
              position = 0;
              continue loop;
            case '}':
              source.consume(2);
              yield Token(type: .blockEnd);
              position = 0;
              continue loop;
            case '(':
              yield* consumeText();
              source.consume(); // @
              yield* const ExplicitExpressionLexer().tokenize(source);
              position = 0;
              continue loop;
            default:
              if (nextChar?.isIdentifierStart != true) throw 'Unexpected end of source';
              yield* consumeText();
              source.consume(); // @
              yield* const ImplicitExpressionLexer().tokenize(source);
              position = 0;
              continue loop;
          }
      }
      ++position;
    } while (position < source.length);

    if (source.isNotEmpty) {
      if (!topLevel && tags.isEmpty) {
        print('Text lexer end: ${source.toString()}');
        return;
      }
      yield Token(type: .text, value: source.substring(0, source.length));
    }
    print('Text lexer end: ${source.toString()}');
  }
}

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
