import 'package:pluto/template/lexer/explicit_expression_lexer.dart';
import 'package:pluto/template/lexer/source_view.dart';
import 'package:pluto/template/lexer/statement_lexer.dart';
import 'package:pluto/template/token.dart';

class IfStatementLexer {
  const IfStatementLexer();

  Iterable<Token> tokenize(SourceView source) sync* {
    // @if consumed

    Iterable<Token> consumeBlock() sync* {
      source.consumeWhiteSpaces();
      source.consumeChar('{');
      yield Token(type: .blockStart);
      print(source);

      // { smt }
      yield* const StatementLexer().tokenize(source);
      print(source);
    }

    // (expr)
    yield* const ExplicitExpressionLexer().tokenize(source);
    print(source);

    // { smt }
    yield* consumeBlock();
    print(source);

    source.consumeWhiteSpaces();
    // else
    if (source.tryConsumeString('else') != null) {
      yield Token(type: .elseStmt);
      print(source);

      // { smt }
      yield* consumeBlock();

      print(source);
    }
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
