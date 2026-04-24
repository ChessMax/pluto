import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/template.dart';
import 'package:test/test.dart';

void main() {
  Node parse(String source) => Parser().parse(Lexer().lex(source).toList());
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

  test('implicit expression should return correct values2', () async {
    final template = getTemplate('@model.name');
    final result = await template.render({'name': 'Ivan'});
    print('result: $result');

    expect(result , 'Ivan');
  });


  test('implicit expression should return correct values', () async {
    final template = getTemplate('<p>@DateTime.now()</p>');
    final result = await template.render(null);
    print('result: $result');

    // <p>2026-04-22 22:20:51.556456</p>
    final regex = RegExp(r'^<p>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6}<\/p>$');
    expect(regex.hasMatch(result) , true);
  });

  test('escape should return correct values', () async {
    final template = getTemplate('<p>@@model</p>');
    final result = await template.render(null);
    print('result: $result');

    expect(result , '<p>@model</p>');
  });
}
