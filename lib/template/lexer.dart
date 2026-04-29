import 'package:pluto/template/analyzer_lexer.dart';
import 'package:pluto/template/token.dart';

class Lexer {
  const Lexer();

  Iterable<Token> lex(String source) sync* {
    int position = 0;

    String? peak() =>
        position < source.length ? source[position] : null;

    String? peakNext() =>
        position + 1 < source.length ? source[position + 1] : null;

    Token consumeText() {
      final start = position;

      do {
        position++;
      } while (position < source.length && source[position] != '@');
      return Token(type: .text, value: source.substring(start, position));
    }

    Token consumeIdentifier() {
      final start = position;

      do {
        position++;
      } while (position < source.length && source[position].isIdentifierContinue);

      return Token(type: .id, value: source.substring(start, position));
    }

    Token consumeExplicitExpression() {
      final end = const AnalyzerLexer().readExpr(source.substring(position));
      if (end != null) {
        final token = Token(type: .expr, value: source.substring(position, position + end));
        position += end;
        return token;
      }
      throw 'Expected explicit expression';
    }

    Token consumeImplicitExpression() {
      final end = const AnalyzerLexer().readImplicitExpr(source.substring(position));
      if (end != null) {
        final token = Token(type: .expr, value: source.substring(position, position + end));
        position += end;
        return token;
      }
      throw 'Expected implicit expression';
    }

    Token consumeStatement() {
      final end = const AnalyzerLexer().readStmt(source.substring(position));
      if (end != null) {
        final token = Token(type: .stmt, value: source.substring(position, position + end));
        position += end;
        return token;
      }
      throw 'Expected statement';
    }

    while (position < source.length) {
      final char = source[position];

      switch (char) {
        case '@':
          position += 1;

          final char = peak();
          // @@
          if (char == '@') {
            position += 1;
            yield Token(type: .text, value: '@'); // TODO: consume text?
            break;
          } // else if @*, @if ...

          else if (char == '(') {
            yield Token(type: .at);
            yield consumeExplicitExpression();
            break;
          } else if (char == '{') {
            yield Token(type: .at);
            yield consumeStatement();
            break;
          }

          // identifier or . ( [ ' "
          yield Token(type: .at);
          yield consumeImplicitExpression();
          break;
        default:
          yield consumeText();
          break;
      }
    }

    yield Token(type: .eof);
  }
}

extension on String {
  bool operator <=(String other) => codeUnitAt(0) <= other.codeUnitAt(0);

  bool operator >=(String other) => codeUnitAt(0) >= other.codeUnitAt(0);

  bool get isDigit => this >= '0' && this <= '9';

  bool get isAlpha => this >= 'a' && this <= 'z' || this >= 'A' && this <= 'Z';

  bool get isIdentifierStart => isAlpha || this == '_' || this == '\$';

  bool get isIdentifierContinue => isIdentifierStart || isDigit;

  bool get isWhiteSpace => this == ' ' || this == '\n' || this == '\t' || this == '\r';
}
