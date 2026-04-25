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

    Iterable<Token> consumeIdentifierOrOperators() sync* {
      for (var char = peak(); char != null; char = peak()) {
        switch (char) {
          case '.': position += 1; yield Token(type: .dot); break;
          case '(': position += 1; yield Token(type: .openParen);
            // TODO: wait for closing
          break;
          case ')': position += 1; yield Token(type: .closeParen);
          // TODO: wait for closing
          break;
        // TODO: (),[],'',""
          default:
            if (char.isIdentifierStart) {
              yield consumeIdentifier();
              break;
            }
            return;
        }
      }
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

          // identifier or . ( [ ' "
          yield Token(type: .at);
          yield* consumeIdentifierOrOperators();
          break;
        default:
          // if (char.isIdentifierStart) {
          //   yield consumeIdentifier();
          //   break;
          // }

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
