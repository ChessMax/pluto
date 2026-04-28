import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:pluto/template/template.dart';
import 'package:test/test.dart';

void main() {
  Node parse(String source) =>
      DocumentNode(Parser().parse(Lexer().lex(source).toList()).toList());
  String codeGen(String source) => CodeGenerator().generate(parse(source));
  Template getTemplate(String source) => Template(codeGen(source));

  test('implicit expression should return correct values 1', () async {
    final template = getTemplate('<p>@model</p>');
    final result = await template.render('Ivan');

    expect(result, '<p>Ivan</p>');
  });

  test('implicit expression should return correct values 2', () async {
    final template = getTemplate('<p>@model.name</p>');
    final result = await template.render({'name': 'Ivan'});

    expect(result, '<p>Ivan</p>');
  });

  test('implicit expression should return correct values 3', () async {
    final template = getTemplate('@model.name');
    final result = await template.render({'name': 'Ivan'});

    expect(result, 'Ivan');
  });

  test('implicit expression should return correct values 4', () async {
    final template = getTemplate('<p>@DateTime.now()</p>');
    final result = await template.render(null);

    // <p>2026-04-22 22:20:51.556456</p>
    final regex = RegExp(
      r'^<p>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{6}<\/p>$',
    );
    expect(regex.hasMatch(result), true);
  });

  test('implicit expression should return correct values 4', () async {
    final template = getTemplate('<p>@DateTime.now().year</p>');
    final result = await template.render(null);

    expect(result, '<p>${DateTime.now().year}</p>');
  });

  test('escape should return correct values 5', () async {
    final template = getTemplate('<p>@@model</p>');
    final result = await template.render(null);
    print('result: $result');

    expect(result, '<p>@model</p>');
  });

  test(
    'simple explicit expr',
    () async {
      final template = getTemplate('<p>@(DateTime.now().year - 1)</p>');
      final result = await template.render(null);
      print('result: $result');

      expect(result, '<p>2025</p>');
    },
  );

  test(
    'simple code block',
    () async {
      final template = getTemplate(
        '''@{ var user = model.name; }<p>@user</p>''',
      );
      final result = await template.render({'name': 'Ivan'});
      print('result: $result');

      expect(result, '<p>Ivan</p>');
    },
  );

  test(
    'simple multiline code block',
        () async {
      final template = getTemplate('''      
@{ 
  var user = model.name; 
}<p>@user</p>''',
      );
      print('---');
      print('''
@{ 
  var user = model.name; 
}<p>@user</p>''');
      print('---');
      final result = await template.render({'name': 'Ivan'});
      print('result: $result');

      expect(result, '<p>Ivan</p>');
    },
  );

  test(
    'simple code block 2',
        () async {
      final template = getTemplate(
        '''@{ var user = model.name; }<p>@user</p>@{ user = 'Peter'; }<p>@user</p>''',
      );
      final result = await template.render({'name': 'Ivan'});
      print('result: $result');

      expect(result, '<p>Ivan</p><p>Peter</p>');
    },
  );
}
