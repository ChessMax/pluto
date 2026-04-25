import 'package:equatable/equatable.dart';

enum TokenType {
  // escape
  at,

  // expressions
  id,
  dot,
  // openParen,
  // closeParen,
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

  String get identifier => value as String;

  @override
  String toString() {
    return '.${type.name}${value != null ? ', $value' : ''}';
  }
}