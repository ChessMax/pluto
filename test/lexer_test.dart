import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/token.dart';
import 'package:test/test.dart';

void main() {
  List<Token> parse(String source) => (const Lexer()).lex(source).toList();
  Token t(TokenType type, [Object? value]) => Token(type: type, value: value);
  Token text(String value) => t(.text, value);
  Token id(String value) => t(.id, value);
  final dot = t(.dot);
  final op = t(.openParen);
  final cp = t(.closeParen);
  final ees = t(.explicitExprStart);
  final eee = t(.explicitExprEnd);
  final bs = t(.blockStart);
  final be = t(.blockEnd);
  Token expr(String value) => t(.explicitExpression, value);
  Token stmt(String value) => t(.statement, value);

  test('empty', () async {
    final result = parse('');
    expect(result, <Token>[t(.eof)]);
  });

  test('ws', () async {
    final result = parse(' ');
    expect(result, <Token>[text(' '), t(.eof)]);
  });

  test('ws 2', () async {
    final result = parse('\t');
    expect(result, <Token>[text('\t'), t(.eof)]);
  });

  test('ws 3', () async {
    final result = parse('\n');
    expect(result, <Token>[text('\n'), t(.eof)]);
  });

  test('lexer', () async {
    final result = parse('Hello, world!');
    expect(result, <Token>[text('Hello, world!'), t(.eof)]);
  });

  test('lexer 1', () async {
    final result = parse('<p>@@model</p>');
    expect(result, <Token>[text('<p>'), text('@'), text('model</p>'), t(.eof)]);
  });

  test('lexer 2', () async {
    final result = parse('<p>@userName</p>');
    expect(result, <Token>[text('<p>'), t(.at), id('userName'), text('</p>'), t(.eof)]);
  });

  test('lexer 3', () async {
    final result = parse('<p>@user.name</p>');
    expect(result, <Token>[text('<p>'), t(.at), id('user'), dot, id('name'), text('</p>'), t(.eof)]);
  });

  test('lexer 4', () async {
    final result = parse('<p>@user.</p>');
    expect(result, <Token>[text('<p>'), t(.at), id('user'), dot, text('</p>'), t(.eof)]);
  });

  test('lexer 5', () async {
    final result = parse('@DateTime.now()');
    expect(result, <Token>[t(.at), id('DateTime'), dot, id('now'), op, cp, t(.eof)]);
  });

  test('lexer 5', () async {
    final result = parse('<p>@DateTime.now()</p>');
    expect(result, <Token>[text('<p>'), t(.at), id('DateTime'), dot, id('now'), op, cp, text('</p>'), t(.eof)]);
  });

  test('lexer 6', () async {
    final result = parse('<p>@(DateTime.now() - 1)</p>');
    expect(result, <Token>[text('<p>'), expr('(DateTime.now() - 1)'), text('</p>'), t(.eof)]);
  });

  test('lexer 7', () async {
    final result = parse('@{ var user = model.name; }<p>@user</p>');
    expect(result, <Token>[stmt('{ var user = model.name; }'), text('<p>'), t(.at), id('user'), text('</p>'), t(.eof)]);
  });
}
