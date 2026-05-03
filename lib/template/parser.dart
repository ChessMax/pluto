import 'package:intl/intl.dart';
import 'package:pluto/template/token.dart';

import 'node.dart';

class Parser {
  const Parser();

  Iterable<Node> parse(List<Token> source) sync* {
    yield* parseDocument(source);
  }

  Iterable<Node> parseDocument(List<Token> source) sync* {
    var position = 0;

    Token? tryConsume(TokenType type) {
      final token = position < source.length ? source[position] : null;
      if (token != null && token.type == type) {
        ++position;
        return token;
      }
      return null;
    }

    Token consumeToken(TokenType type) {
      return tryConsume(type) ?? (throw 'Expected token $type');
    }

    Node parseMarkupStatement() {
      if (tryConsume(.at) != null) {
        if (tryConsume(.expr) case final exprToken?) {
          return ExpressionNode(exprToken.code);
        } else {
          throw 'Expected expression not found';
        }
      } else
      if (tryConsume(.text) case final textToken?) {
        return TextNode(textToken.text);
      } else if (tryConsume(.expr) case final exprToken?) {
        return ExpressionNode(exprToken.code);
      }

      throw 'Unexpected markup statement';
    }

    Node consumeMarkup() {
      final openTag = position < source.length ? source[position] : (throw 'Expected open tag but eof found');
      final children = <Node>[TextNode(openTag.toString())];
      ++position; // consume openTag
      // while (position < source.length && source[position].type != .closingTag) {
      //   children.add(parseMarkupStatement());
      // }
      while (position < source.length) {
        final token = source[position];
        if (token.type != .closingTag) {
          children.add(parseMarkupStatement());
        } else {
          break;
        }
      }
      final closeTag = consumeToken(.closingTag);
      if (closeTag.text != openTag.text) {
        throw 'Unbalanced tags $openTag:$closeTag';
      }
      children.add(TextNode(closeTag.toString()));
      return MarkupNode(children);
    }

    Node consumeStatement() {
      final token = source[position];
      if (token.type == .openTag) {
        return consumeMarkup();
      } else if (token.type == .stmt) {
        position++;
        return StatementNode(token.code);
      }
      throw 'Unexpected token: $token';
    }

    Node consumeBlock() {
      final children = <Node>[];
      while (position < source.length && source[position].type != .blockEnd) {
        children.add(consumeStatement());
      }
      consumeToken(.blockEnd);
      return BlockNode(children);
    }

    Iterable<Node> consumeTokens() sync* {
      while (position < source.length) {
        if (tryConsume(.at) != null) {
          if (tryConsume(.expr) case final exprToken?) {
            yield ExpressionNode(exprToken.code);
          } else {
            throw 'Expected expression not found';
          }
        } else
        if (tryConsume(.blockStart) != null) {
          yield consumeBlock();
        } else if (tryConsume(.text) case final textToken?) {
          yield TextNode(textToken.text);
        } else if (source[position].type == .openTag) {
          yield consumeMarkup();
        }
      }
    }

    yield DocumentNode(consumeTokens().toList());
  }
}
