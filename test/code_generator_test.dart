import 'dart:io';

import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:test/test.dart';

void main() {
  String code(String value) => CodeGenerator.header + value + CodeGenerator.footer;
  Node parse(String source) => DocumentNode(Parser().parse(Lexer().tokenize(source).toList()).toList());
  String codeGen(String source) => CodeGenerator().generate(parse(source));

  test('code gen', () async {
    final actualCode = codeGen('<p>@model</p>');
    final expectedCode = code(
'''
  result += '<p>';
  result += model.toString();
  result += '</p>';
'''
    );
    expect(actualCode, expectedCode);
  });
  test('code gen2', () async {
    final actualCode = codeGen('<p>@model.name</p>');
    final expectedCode = code(
'''
  result += '<p>';
  result += model.name.toString();
  result += '</p>';
'''
    );
    print(actualCode);
    print('');
    print(expectedCode);
    expect(actualCode, expectedCode);
  });
}
