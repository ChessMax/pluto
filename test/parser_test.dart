import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/token.dart';
import 'package:test/test.dart';

void main() {
  Token t(TokenType type, [Object? value]) => Token(type: type, value: value);

  Token id(String value) => Token(type: .identifier, value: value);
  Token l(String literal) => Token(type: .literal, value: literal);

  Node parse(String source) => Parser().parse(Lexer().lex(source).toList());

  test('parser', () async {
    final result = parse('<p>@model</p>').toString();
    expect(result, '<p>model</p>');
  });

  test('parser2', () async {
    final result = (parse('<p>@model.name</p>') as DocumentNode).children.map((n) => n.toString()).toList();
    expect(result.join(', '), '<p>, model.name, </p>');
  });

  test('parser3', () async {
    final result = (parse('<p>@DateTime.now()</p>') as DocumentNode).children.map((n) => n.toString()).toList();
    expect(result.join(', '), '<p>, DateTime.now(), </p>');
  });

  test('parser2', () async {
    final result = (parse('<p>@@model</p>') as DocumentNode).children.map((n) => n.toString()).toList();
    expect(result.join(', '), '<p>, @model, </p>');
  });
}
