import 'package:intl/intl.dart';
import 'package:pluto/template/token.dart';

import 'node.dart';

class Parser {
  const Parser();

  Node parse(List<Token> tokens) {
    List<Node> nodes = [];

    int position = 0;

    Token? peak() =>
        position >= 0 && position < tokens.length ? tokens[position] : null;
    Token? peakNext() => position + 1 >= 0 && position + 1 < tokens.length
        ? tokens[position + 1]
        : null;

    void consume(String reason) {
      ++position;
      // print('Consume: $reason');
    }

    Token? tryConsumeToken(TokenType type) {
      final token = peak();
      if (token == null || token.type != type) return null;
      consume('try consume $type');
      return token;
    }

    Token consumeToken(TokenType type) {
      final token = tryConsumeToken(type) ?? (throw 'Expected $type token');
      return token;
    }

    String consumeId() => consumeToken(.identifier).identifier;
    String? tryConsumeId() => tryConsumeToken(.identifier)?.identifier;

    // print('tokens: ${tokens.map((t) => '.${t.type.name}${t.value != null ? '(${t.value})' : ''}').toList()}');

    // tokens: [.lt, .identifier(p), .gt, .at, .identifier(model), .lt, .slash, .identifier(p), .gt, .eof]
    while (position < tokens.length) {
      final token = tokens[position];
      final String ts = tokens
          .sublist(position)
          .map((t) => '.${t.type.name}${t.value != null ? '(${t.value})' : ''}')
          .join(', ');
      // print('Current token: ' + token.toString());
      // print('tokens: ${ts}');

      switch (token.type) {
        case TokenType.at:
          consume('@');
          if (peak()?.type == .at) {
            consume('@');
            final id = tryConsumeId();
            if (id != null) {
              nodes.add(MarkupNode('@$id'));
            } else {
              nodes.add(MarkupNode('@'));
            }
            break;
          }
          final id = consumeId();
          final nextToken = peak();
          if (nextToken != null && nextToken.type == .dot) {
            consume('.');
            final id2 = consumeId();

            final nextNextToken = peak();
            final nextNextNextToken = peakNext();
            if (nextNextToken != null &&
                nextNextToken.type == .openParen &&
                nextNextNextToken != null &&
                nextNextNextToken.type == .closeParen) {
              consume('(');
              consume(')');
              nodes.add(ImplicitExpressionNode('$id.$id2()'));
              break;
            }

            nodes.add(ImplicitExpressionNode('$id.$id2'));
            break;
          }
          nodes.add(ImplicitExpressionNode(id));
          break;
        case TokenType.dot:
          consume('.');
          final id = consumeId();
          nodes.add(ImplicitExpressionNode('.$id'));
        case TokenType.identifier:
          throw UnimplementedError();
        case TokenType.literal:
          throw UnimplementedError();
        case TokenType.lt:
          consume('<');
          final slash = tryConsumeToken(.slash);
          final id = consumeId();
          consumeToken(.gt);
          if (slash != null) {
            nodes.add(MarkupNode('</$id>'));
          } else {
            nodes.add(MarkupNode('<$id>'));
          }

          break;
        case TokenType.gt:
          throw UnimplementedError();
        case TokenType.slash:
          throw UnimplementedError();
        case TokenType.eof:
          consume('eof');
          if (position < tokens.length) {
            throw 'Expected eof last token';
          }
          break;
        case TokenType.openParen:
          // TODO: Handle this case.
          throw UnimplementedError();
        case TokenType.closeParen:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }
    return DocumentNode(nodes);
  }
}
