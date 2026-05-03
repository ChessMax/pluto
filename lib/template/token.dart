import 'package:equatable/equatable.dart';

enum TokenType {
  // escape
  at,
  stmt,
  expr,
  blockStart,
  blockEnd,

  ifStmt,

  // expressions
  openTag,
  closingTag,

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
      .at => '@',
      .blockStart => '@{',
      .blockEnd => '}',
      .openTag => '<$value>',
      .closingTag => '</$value>',
      .stmt => '```$code```',
      .expr => '`$code`',
      .ifStmt => throw UnimplementedError(),
      .text => text,
      .eof => '',
    };
  }
}