import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:test/test.dart';

void main() {
  String parse(String source) => DocumentNode(
    const Parser().parse(const Lexer().lex(source).toList()).toList(),
  ).toString();

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
    expect(result,  '\n' );
  });

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
    expect(result, '<p>`model`</p>');
  });

  test('parser 3', () async {
    final result = parse('<p>@user.name</p>');
    expect(result, '<p>`user.name`</p>');
  });

  test('parser 4', () async {
    final result = parse('<p>@user.</p>');
    expect(result, '<p>`user`.</p>');
  });

  test('parser 5', () async {
    final result = parse('@DateTime.now()');
    expect(result, '`DateTime.now()`');
  });

  test('parser 6', () async {
    final result = parse('<p>@DateTime.now()</p>');
    expect(result, '<p>`DateTime.now()`</p>');
  });

  test('parser 7', () async {
    final result = parse('<p>@DateTime.now().year</p>');
    expect(result, '<p>`DateTime.now().year`</p>');
  });

  // TODO: call with args, strings, indexers.
  test('lexer 8', () async {
    final result = parse('<p>@(DateTime.now() - 1)</p>');
    expect(result, '<p>`(DateTime.now() - 1)`</p>');
  });

  test('lexer 9', () async {
    final result = parse('@{ var user = model.name; }<p>@user</p>');
    expect(result, '```{ var user = model.name; }```<p>`user`</p>');
  });

}
