import 'package:pluto/template/lexer.dart';
import 'package:pluto/template/token.dart';
import 'package:test/test.dart';

void main() {
  Token t(TokenType type, [Object? value]) => Token(type: type, value: value);

  Token id(String value) => Token(type: .identifier, value: value);
  Token l(String literal) => Token(type: .literal, value: literal);

  test('lexer', () async {
    final result = Lexer('<p>@@model</p>').lex().toList();
    expect(result, <Token>[t(.lt), id('p'), t(.gt), t(.at), t(.at), id('model'), t(.lt), t(.slash), id('p'), t(.gt), t(.eof)]);
  });

  test('lexer2', () async {
    final result = Lexer('<p>@userName</p>').lex().toList();
    expect(result, <Token>[t(.lt), id('p'), t(.gt), t(.at), id('userName'), t(.lt), t(.slash), id('p'), t(.gt), t(.eof)]);
  });
}
