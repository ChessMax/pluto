import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/token.dart';
import 'package:test/test.dart';

void main() {
  Token t(TokenType type, [Object? value]) => Token(type: type, value: value);

  Token id(String value) => Token(type: .id, value: value);
  Token text(String value) => Token(type: .text, value: value);

  String parse(String source) => DocumentNode(
    const Parser().parse(const Lexer().lex(source).toList()).toList(),
  ).toString();

  // test('empty', () async {
  //   final result = Lexer().lex('').toList();
  //   expect(result, <Token>[t(.eof)]);
  // });
  //
  // test('ws', () async {
  //   final result = Lexer().lex(' ').toList();
  //   expect(result, <Token>[text(' '), t(.eof)]);
  // });
  //
  // test('ws 2', () async {
  //   final result = Lexer().lex('\t').toList();
  //   expect(result, <Token>[text('\t'), t(.eof)]);
  // });
  //
  // test('ws 3', () async {
  //   final result = Lexer().lex('\n').toList();
  //   expect(result, <Token>[text('\n'), t(.eof)]);
  // });
  //
  test('parser', () async {
    final result = parse('Hello, world!');
    expect(result, 'Hello, world!');
  });

  test('parser 1', () async {
    final result = parse('<p>@@model</p>');
    expect(result, '<p>@model</p>');
  });

  test('parser 2', () async {
    final result = parse('<p>@model</p>');
    expect(result, '<p>model</p>');
  });

  test('parser 3', () async {
    final result = parse('<p>@user.name</p>');
    expect(result, '<p>user.name</p>');
  });

  test('parser 4', () async {
    final result = parse('<p>@user.</p>');
    expect(result, '<p>user.</p>');
  });
  // =====
  // test('parser', () async {
  //   final result = parse('<p>@model</p>').toString();
  //   expect(result, '<p>model</p>');
  // });
  //
  // test('parser2', () async {
  //   final result = (parse('<p>@model.name</p>') as DocumentNode).children.map((n) => n.toString()).toList();
  //   expect(result.join(', '), '<p>, model.name, </p>');
  // });
  //
  // test('parser3', () async {
  //   final result = (parse('<p>@DateTime.now()</p>') as DocumentNode).children.map((n) => n.toString()).toList();
  //   expect(result.join(', '), '<p>, DateTime.now(), </p>');
  // });
  //
  // test('parser2', () async {
  //   final result = (parse('<p>@@model</p>') as DocumentNode).children.map((n) => n.toString()).toList();
  //   expect(result.join(', '), '<p>, @model, </p>');
  // });
  //
  // test('parser2', () async {
  //   final result = (parse('Hello, world!') as DocumentNode).children.map((n) => n.toString()).toList();
  //   expect(result.join(', '), 'Hello, world!');
  // });
}
