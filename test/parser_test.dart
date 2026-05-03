import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:test/test.dart';

void main() {
  String parse(String source) => DocumentNode(
    const Parser().parse(const Lexer().tokenize(source).toList()).toList(),
  ).toString();

  test('Code block with markup', () async {
    final result = parse('''@{ var name = 'User';<p>Hello, @name</p> }''');
    expect(result,         '@{``` var name = \'User\';```<p>Hello, `name`</p>``` ```}');
  });

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

  test('lexer 41', () async {
    final result = parse('<p>@user[\'name\']</p>');
    expect(result, '<p>`user[\'name\']`</p>');
  });

  test('parser 5', () async {
    final result = parse('@DateTime.now()');
    expect(result, '`DateTime.now()`');
  });

  test('lexer 51', () async {
    final result = parse('@DateTime.now(1, \'user\', 2.0, [], item.name)');
    expect(result, '`DateTime.now(1, \'user\', 2.0, [], item.name)`');
  });

  test('lexer 52', () async {
    final result = parse('<p>@DateTime.now()</p>');
    expect(result, '<p>`DateTime.now()`</p>');
  });

  test('lexer 6', () async {
    final result = parse('<p>@(DateTime.now() - 1)</p>');
    expect(result, '<p>`(DateTime.now() - 1)`</p>');
  });

  test('parser 7', () async {
    final result = parse('<p>@DateTime.now().year</p>');
    expect(result, '<p>`DateTime.now().year`</p>');
  });

  // // TODO: call with args, strings, indexers.
  test('lexer 8', () async {
    final result = parse('@{ var user = model.name; }<p>@user</p>');
    expect(result, '@{``` var user = model.name; ```}<p>`user`</p>');
  });

  test('lexer 9', () async {
    final result = parse('@{ var user = model.name; <p>@user</p> }');
    expect(result, '@{``` var user = model.name; ```<p>`user`</p>``` ```}');
  });


  test('Code block with markup 2', () async {
    final result = parse('''@{ var name = 'User';<p>Hello</p> }''');
    expect(result, '@{``` var name = \'User\';```<p>Hello</p>``` ```}');
  });

  test('html', () async {
    final result = parse('123 <p>Hello, World!</p> 321');
    expect(result, '123 <p>Hello, World!</p> 321');
  });

}
