import 'package:intl/intl.dart';
import 'package:pluto/template/token.dart';

import 'node.dart';

class Parser {
  const Parser();

  Iterable<Node> parse(List<Token> source) sync* {
    yield* parseDocument(source);
  }

  Iterable<Node> parseDocument(List<Token> source) sync* {
    int position = 0;

    Token? peek() => position < source.length ? source[position] : null;
    Token? peekNext() =>
        position + 1 < source.length ? source[position + 1] : null;
    bool isAtEnd() => position >= source.length;

    Token consumeToken(TokenType type) {
      final token = peek();
      if (token != null && token.type == type) {
        position += 1;
        return token;
      } else {
        throw 'Expected $type not found';
      }
    }

    bool tryConsumeToken(TokenType type) {
      final token = peek();
      if (token != null && token.type == type) {
        position += 1;
        return true;
      } else {
        return false;
      }
    }

    Node parseText() {
      var text = '';

      loop:
      for (var token = peek(); token != null; token = peek()) {
        switch (token.type) {
          case .text:
            position += 1;
            text += token.text;
            break;

          case .at:
          case .openParen:
          case .closeParen:
          case .eof:
          case .stmt:
          case .expr:
            break loop;
          case TokenType.ifStmt:
            throw UnimplementedError();
        }
      }

      return TextNode(text);
    }

    Node parseStatement() {
      // TODO: hangs if there is no at
      if (tryConsumeToken(.at)) {
        if (tryConsumeToken(.expr)) {
          final expression = source[position - 1].code;
          return ExpressionNode(expression);
        } else if (tryConsumeToken(.stmt)) {
          return StatementExpressionNode(source[position - 1].code);
        }
        throw 'Expected implicit or explicit expression or code block';
      }
      return parseText();
    }

    final nodes = <Node>[];
    while (!isAtEnd() && peek()?.type != TokenType.eof) {
      nodes.add(parseStatement());
    }
    consumeToken(TokenType.eof);
    yield DocumentNode(nodes);
  }
}
