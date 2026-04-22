import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/template.dart';
import 'package:test/test.dart';

void main() {
  Node parse(String source) => Parser().parse(Lexer(source).lex().toList());
  String codeGen(String source) => CodeGenerator().generate(parse(source));
  Template getTemplate(String source) => Template(codeGen(source));

  test('implicit expression should return correct values', () async {
    final template = getTemplate('<p>@model</p>');
    final result = await template.render('Ivan');
    print('result: $result');

    expect(result , '<p>Ivan</p>');
  });

  test('implicit expression should return correct values', () async {
    final template = getTemplate('<p>@model.name</p>');
    final result = await template.render({'name': 'Ivan'});
    print('result: $result');

    expect(result , '<p>Ivan</p>');
  });

  test('escape should return correct values', () async {
    final template = getTemplate('<p>@@userName</p>');
    final result = await template.render(null);
    print('result: $result');

    expect(result , '<p>@userName</p>');
  });

  test('inline expressions should work', () async {
    final template = getTemplate('<b>@DateTime.now()</b>');
    final result = await template.render(null);
    print('result: $result');

    expect(result.length, 33);
    expect(result.startsWith('<b>'), isTrue);
    expect(result.endsWith('</b>'), isTrue);
  });
}
