import 'package:equatable/equatable.dart';

enum TokenType {
  // escape
  at,
  stmt,
  expr,

  ifStmt,

  // expressions
  openParen,
  closeParen,
  // openBracket,
  // closeBracket,
  // stringLiteral,

  // common
  text,
  eof;

  const TokenType();
}

class Token extends Equatable {
  final TokenType type;
  final Object? value;

  Token({required this.type, this.value});

  @override
  List<Object?> get props => [type, value];

  String get text => value as String;
  String get code => value as String;

  @override
  String toString() {
    return switch (type) {
      TokenType.at => '@',
      TokenType.stmt => '```$code```',
      TokenType.expr => '`$code`',
      TokenType.ifStmt => throw UnimplementedError(),
      TokenType.openParen => '(',
      TokenType.closeParen => ')',
      TokenType.text => text,
      TokenType.eof => '',
    };
  }
}