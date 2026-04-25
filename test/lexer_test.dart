import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/token.dart';
import 'package:test/test.dart';

void main() {
  Token t(TokenType type, [Object? value]) => Token(type: type, value: value);
  Token text(String value) => t(.text, value);
  Token id(String value) => t(.id, value);
  final dot = t(.dot);
  final op = t(.openParen);
  final cp = t(.closeParen);

  test('empty', () async {
    final result = Lexer().lex('').toList();
    expect(result, <Token>[t(.eof)]);
  });

  test('ws', () async {
    final result = Lexer().lex(' ').toList();
    expect(result, <Token>[text(' '), t(.eof)]);
  });

  test('ws 2', () async {
    final result = Lexer().lex('\t').toList();
    expect(result, <Token>[text('\t'), t(.eof)]);
  });

  test('ws 3', () async {
    final result = Lexer().lex('\n').toList();
    expect(result, <Token>[text('\n'), t(.eof)]);
  });

  test('lexer', () async {
    final result = Lexer().lex('Hello, world!').toList();
    expect(result, <Token>[text('Hello, world!'), t(.eof)]);
  });

  test('lexer 1', () async {
    final result = Lexer().lex('<p>@@model</p>').toList();
    expect(result, <Token>[text('<p>'), text('@'), text('model</p>'), t(.eof)]);
  });

  test('lexer 2', () async {
    final result = Lexer().lex('<p>@userName</p>').toList();
    expect(result, <Token>[text('<p>'), t(.at), id('userName'), text('</p>'), t(.eof)]);
  });

  test('lexer 3', () async {
    final result = Lexer().lex('<p>@user.name</p>').toList();
    expect(result, <Token>[text('<p>'), t(.at), id('user'), dot, id('name'), text('</p>'), t(.eof)]);
  });

  test('lexer 4', () async {
    final result = Lexer().lex('<p>@user.</p>').toList();
    expect(result, <Token>[text('<p>'), t(.at), id('user'), dot, text('</p>'), t(.eof)]);
  });

  test('lexer 5', () async {
    final result = Lexer().lex('@DateTime.now()').toList();
    expect(result, <Token>[t(.at), id('DateTime'), dot, id('now'), op, cp, t(.eof)]);
  });

  test('lexer 5', () async {
    final result = Lexer().lex('<p>@DateTime.now()</p>').toList();
    expect(result, <Token>[text('<p>'), t(.at), id('DateTime'), dot, id('now'), op, cp, text('</p>'), t(.eof)]);
  });
}
