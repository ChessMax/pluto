import 'dart:io';

import 'package:pluto/template/code_generator.dart';
import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/node.dart';
import 'package:pluto/template/parser.dart';
import 'package:test/test.dart';

void main() {

  Node parse(String source) => Parser().parse(Lexer(source).lex().toList());
  String codeGen(String source) => CodeGenerator().generate(parse(source));

  test('code gen', () async {
    final actualCode = codeGen('<p>@model</p>');
    final expectedCode =
'''
import 'dart:isolate';

void main(List<String> args, dynamic message) {
  final replyTo = message[0] as SendPort;
  final model = message[1];
  String result = '';

  result += '<p>';
  result += model.toString();
  result += '</p>';
  replyTo.send(result);
}
''';
    // File('actual_code.dart').writeAsStringSync(actualCode);
    // File('expected_code.dart').writeAsStringSync(expectedCode);
    print(actualCode);
    print('');
    print(expectedCode);
    expect(actualCode, expectedCode);
  });

}
