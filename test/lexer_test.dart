import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/token.dart';
import 'package:test/test.dart';

void main() {
  String parse(String source) => (const Lexer()).lex(source).map((t) => t.toString()).join();
  Token t(TokenType type, [Object? value]) => Token(type: type, value: value);

  test('empty', () async {
    final result = parse('');
    expect(result, '');
  });

  test('ws', () async {
    final result = parse(' ');
    expect(result, ' ');
  });

  test('ws 2', () async {
    final result = parse('\t');
    expect(result, '\t');
  });

  test('ws 3', () async {
    final result = parse('\n');
    expect(result, '\n');
  });

  test('lexer', () async {
    final result = parse('Hello, world!');
    expect(result, 'Hello, world!');
  });

  test('lexer 1', () async {
    final result = parse('<p>@@model</p>');
    expect(result, '<p>@model</p>');
  });

  test('lexer 2', () async {
    final result = parse('<p>@model</p>');
    expect(result, '<p>@`model`</p>');
  });

  test('lexer 3', () async {
    final result = parse('<p>@user.name</p>');
    expect(result, '<p>@`user.name`</p>');
  });

  test('lexer 4', () async {
    final result = parse('<p>@user.</p>');
    expect(result, '<p>@`user`.</p>');
  });

  test('lexer 41', () async {
    final result = parse('<p>@user[\'name\']</p>');
    expect(result, '<p>@`user[\'name\']`</p>');
  });

  test('lexer 5', () async {
    final result = parse('@DateTime.now()');
    expect(result, '@`DateTime.now()`');
  });

  test('lexer 51', () async {
    final result = parse('@DateTime.now(1, \'user\', 2.0, [], item.name)');
    expect(result, '@`DateTime.now(1, \'user\', 2.0, [], item.name)`');
  });

  test('lexer 52', () async {
    final result = parse('<p>@DateTime.now()</p>');
    expect(result, '<p>@`DateTime.now()`</p>');
  });

  test('lexer 6', () async {
    final result = parse('<p>@(DateTime.now() - 1)</p>');
    expect(result, '<p>@`(DateTime.now() - 1)`</p>');
  });

  test('parser 7', () async {
    final result = parse('<p>@DateTime.now().year</p>');
    expect(result, '<p>@`DateTime.now().year`</p>');
  });

  test('lexer 8', () async {
    final result = parse('@{ var user = model.name; }<p>@user</p>');
    expect(result, '@```{ var user = model.name; }```<p>@`user`</p>');
  });

//   test('lexer 7', () async {
//     final result = parse('''
// @{
//   var user = {'name': 'Ivan'};
//   <text>User name: @user.name</text>
// }''');
//     expect(result, '''
// @```{
//   var user = {'name': 'Ivan'};
//   <text>User name: @`user.name`</text>
// }```''');
//   });

  // test('lexer 8', () async {
  //   final result = parse('@if (true) { <text>true</text> } else { <text>false</text> }');
  //   expect(result, <Token>[at, ifStmt('(true)'), text('<p>'), at, id('user'), text('</p>'), t(.eof)]);
  // });
}
