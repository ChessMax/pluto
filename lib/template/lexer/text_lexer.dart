import 'package:pluto/template/lexer/explicit_expression_lexer.dart';
import 'package:pluto/template/lexer/implicit_expression_lexer.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/statement_lexer.dart';
import 'package:pluto/template/token.dart';

class TextLexer {
  const TextLexer();

  Iterable<Token> tokenize(SourceView source) sync* {
    int getTransitionIndex() {
      var index = -1;

      do {
        index = source.indexOf('@', index + 1);

        if (index == -1) return -1;
        if (source.peakNext(index + 1) != '@') {
          return index;
        }
      } while (index < source.length);

      return index;
    }

    do {
      final index = getTransitionIndex();

      if (index == -1) {
        var index = source.indexOf('>');
        yield Token(type: .text, value: source.substring(0, index + 1));
        source.consume(index + 1);
        return;
      }

      if (index > 0) {
        yield Token(type: .text, value: source.substring(0, index));
      }
      yield Token(type: .at);

      source.consume(index + 1);

      final char = source.peak();

      switch (char) {
        case '{':
          yield* const StatementLexer().tokenize(source);
          return;
        case '(':
          yield* const ExplicitExpressionLexer().tokenize(source);
          break;

        default:
          if (char?.isIdentifierStart != true) throw 'Unexpected end of source';
          yield* const ImplicitExpressionLexer().tokenize(source);
          break;
      }
    } while (source.isNotEmpty);
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
